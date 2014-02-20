module Peekarails
  class ActionControllerInstrument < Base

    def initialize
    end

    def setup
      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, start, finish, id, payload|
        target = "#{payload[:controller]}##{payload[:action]}"

        timestamp = Time.now.to_i

        redis.pipelined do
          redis.sadd 'controllers', target

          GRANULARITIES.each do |name, granularity|
            bucket = round_timestamp timestamp, granularity

            key = "controllers:#{target}:#{name}:#{bucket}"
            index = factor_timestamp(timestamp, granularity)

            redis.hincrby key, index, 1
            redis.expireat key, bucket + granularity[:ttl]

            total = "controllers:total:#{name}:#{bucket}"

            redis.hincrby total, index, 1
            redis.expireat total, bucket + granularity[:ttl]
          end
        end
      end
    end

    def total granularity
      bucket = round_timestamp Time.now.to_i, GRANULARITIES[granularity]
      redis.hgetall "controllers:total:#{granularity}:#{bucket}"
    end

    def children
      redis.smembers 'controllers'
    end
  end
end
