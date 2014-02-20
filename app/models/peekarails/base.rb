class Peekarails::Base

  GRANULARITIES = {
    five_seconds: { # kept for 1 hour
      size:   720,
      ttl:    7200,
      factor: 5
    },

    minutes: { # Available for 24 hours
      size:   1440,   # Minutes in 24 hours
      ttl:    172800, # Seconds in 48 hours
      factor: 60      # Number of seconds that make up this granularity
    },

    hours: { # Available for one week
      size:   168,     # Hours in one week
      ttl:    1209600, # Seconds in two weeks
      factor: 3600     # Seconds in one hour
    },

    days: { # Available for 30 days
      size:   30,      # Days in one month
      ttl:    5184000, # Seconds in 60 days
      factor: 86400    # Seconds in one day
    },

    months: { # Available for 1 year
      size:   12,       # Months in one year
      ttl:    63072000, # Seconds in 2 years
      factor: 2592000   # Seconds in 1 month
    }
  }

  def setup
    raise "Not implemented"
  end

  def round_timestamp timestamp, granularity
    factor = granularity[:size] * granularity[:factor]

    (timestamp / factor) * factor
  end

  def factor_timestamp timestamp, granularity
    (timestamp / granularity[:factor]) * granularity[:factor]
  end

  def redis
    Peekarails.redis
  end
end
