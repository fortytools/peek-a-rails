require 'redis/namespace'

require 'peekarails/engine'

module Peekarails

  def self.configure
    yield self
  end

  # Accepts:
  #   1. A 'hostname:port' String
  #   2. A 'hostname:port:db' String (to select the Redis db)
  #   3. A 'hostname:port/namespace' String (to set the Redis namespace)
  #   4. A Redis URL String 'redis://host:port'
  #   5. An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`,
  #      or `Redis::Namespace`.
  #   6. An Hash of a redis connection {:host => 'localhost', :port => 6379, :db => 0}
  def self.redis=(server)
    case server
    when String
      if server =~ /redis\:\/\//
        redis = Redis.new(:url => server, :thread_safe => true, :timeout => 1.0)
      else
        server, namespace = server.split('/', 2)
        host, port, db = server.split(':')
        redis = Redis.new(:host => host, :port => port,
          :thread_safe => true, :db => db, :timeout => 1.0)
      end
      namespace ||= :resque

      @redis = Redis::Namespace.new(namespace, :redis => redis)
    when Redis::Namespace
      @redis = server
    when Hash
      @redis = Redis::Namespace.new(:resque, :redis => Redis.new(server))
    else
      @redis = Redis::Namespace.new(:resque, :redis => server)
    end
  end

  # Returns the current Redis connection. If none has been created, will
  # create a new one.
  def self.redis
    return @redis if @redis
    self.redis = Redis.respond_to?(:connect) ? Redis.connect : "localhost:6379"
    self.redis
  end
end
