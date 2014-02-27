module Peekarails::Metrics

  GRANULARITIES = {
    five_seconds: { # kept for 1 hour
      size:   720,
      ttl:    7200,
      factor: 5,
      name: 'Realtime'
    },

    five_minutes: { # Available for 24 hours
      size:   288,    # Minutes in 24 hours
      ttl:    172800, # Seconds in 48 hours
      factor: 300,    # Number of seconds that make up this granularity
      name: 'Last 24 hours'
    },

    hours: { # Available for one week
      size:   168,     # Hours in one week
      ttl:    1209600, # Seconds in two weeks
      factor: 3600,    # Seconds in one hour
      name: 'Last week'
    },

    days: { # Available for 30 days
      size:   30,      # Days in one month
      ttl:    5184000, # Seconds in 60 days
      factor: 86400,   # Seconds in one day
      name: 'Last month'
    },

    months: { # Available for 1 year
      size:   12,       # Months in one year
      ttl:    63072000, # Seconds in 2 years
      factor: 2592000,  # Seconds in 1 month
      name: 'Last year'
    }
  }

  class << self

    def round_timestamp timestamp, granularity
      factor = granularity[:size] * granularity[:factor]

      (timestamp / factor) * factor
    end

    def factor_timestamp timestamp, granularity
      (timestamp / granularity[:factor]) * granularity[:factor]
    end

    def granularity_info granularity
      GRANULARITIES[granularity] or raise "Granularity #{granularity} does not exist"
    end

    def redis
      Peekarails.redis
    end

    def record! context
      timestamp = Time.now.to_i

      method = context[:method]
      path = context[:path]
      action = context[:action] || 'Unknown'
      duration = context[:duration]
      status = context[:status]

      redis.pipelined do
        redis.sadd 'controllers.actions', action
        redis.sadd 'controllers.methods', methods
        redis.sadd 'controllers.status', status

        GRANULARITIES.each do |name, granularity|
          bucket = round_timestamp timestamp, granularity
          index = factor_timestamp(timestamp, granularity)

          key = "controllers:total:#{method}:#{name}:#{bucket}"
          redis.hincrby key, index, 1
          redis.expireat key, bucket + granularity[:ttl]

          if context[:error]
            key = "requests:error:count:#{name}:#{bucket}"
            redis.hincrby key, index, 1
            redis.expireat key, bucket + granularity[:ttl]
          else
            key = "controllers:#{action}:count:#{name}:#{bucket}"
            redis.hincrby key, index, 1
            redis.expireat key, bucket + granularity[:ttl]

            key = "controllers:#{action}:duration:#{name}:#{bucket}"
            redis.hincrby key, index, duration
            redis.expireat key, bucket + granularity[:ttl]

            key = "controllers:total:count:#{name}:#{bucket}"
            redis.hincrby key, index, 1
            redis.expireat key, bucket + granularity[:ttl]

            key = "controllers:total:duration:#{name}:#{bucket}"
            redis.hincrby key, index, duration
            redis.expireat key, bucket + granularity[:ttl]

            key = "controllers:total:#{status}:#{name}:#{bucket}"
            redis.hincrby key, index, 1
            redis.expireat key, bucket + granularity[:ttl]

            key = "system.gc.minor:#{name}:#{bucket}"
            redis.hincrby key, index, context[:gc_minor_count]
            redis.expireat key, bucket + granularity[:ttl]

            key = "system.gc.major:#{name}:#{bucket}"
            redis.hincrby key, index, context[:gc_major_count]
            redis.expireat key, bucket + granularity[:ttl]
          end
        end
      end
    end

    def query granularity_name, key_prefix, from, to
      from = from.to_i
      to = to.to_i

      raise "Invalid range" if from >= to

      granularity = granularity_info(granularity_name)

      min = round_timestamp(Time.now.to_i, granularity) - granularity[:ttl]

      from = [factor_timestamp(from, granularity), min].max
      to = factor_timestamp(to, granularity)

      result = {}

      cache = {}

      [round_timestamp(from, granularity),
        round_timestamp(to, granularity)].uniq.each do |bucket|

        key = "#{key_prefix}:#{granularity_name}:#{bucket}"

        cache[bucket] = redis.hgetall key
      end

      index = from
      while index <= to do
        bucket = round_timestamp index, granularity

        cached = cache[bucket]

        result[index] = if cached
          cached[index.to_s].to_i || 0
        else
          0
        end

        index += granularity[:factor]
      end

      return result
    end

    def total_count granularity
      bucket = round_timestamp Time.now.to_i, granularity_info(granularity)
      redis.hgetall "controllers:total:count:#{granularity}:#{bucket}"
    end

    def total_duration granularity
      bucket = round_timestamp Time.now.to_i, granularity_info(granularity)
      redis.hgetall "controllers:total:duration:#{granularity}:#{bucket}"
    end

    def total_status granularity, from, to
      redis.smembers('controllers.status').map do |status|
        {
          status: status,
          data: query(granularity, "controllers:total:#{status}", from, to)
        }
      end
    end

    def gc_runs granularity, from, to
      ['minor', 'major'].map do |gc|
        {
          gc: gc,
          data: query(granularity, "system.gc.#{gc}", from, to)
        }
      end
    end

    def count action, granularity
      bucket = round_timestamp Time.now.to_i, granularity_info(granularity)
      redis.hgetall "controllers:#{action}:count:#{granularity}:#{bucket}"
    end

    def duration action, granularity
      bucket = round_timestamp Time.now.to_i, granularity_info(granularity)
      redis.hgetall "controllers:#{action}:duration:#{granularity}:#{bucket}"
    end

    def actions
      redis.smembers 'controllers.actions'
    end
  end

end