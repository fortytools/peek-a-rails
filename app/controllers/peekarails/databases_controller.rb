require_dependency "peekarails/base_controller"

module Peekarails
  class DatabasesController < BaseController

    WRITE_QUERIES = [ 'INSERT', 'UPDATE' ]
    READ_QUERIES = [ 'SELECT' ]

    def show
      queries = Metrics.queries(@granularity_key, @from, @to)
      duration = Metrics.query_duration(@granularity_key, @from, @to)

      @all_queries_json = queries.map do |query|
        if query[:data]
          {
            name: query[:query],
            data: query[:data].map do |timestamp, count|
              {x: timestamp, y: count}
            end
          }
        end
      end.compact.to_json

      @write_queries_json = queries.map do |query|
        if query[:data] && WRITE_QUERIES.include?(query[:query])
          {
            name: query[:query],
            data: query[:data].map do |timestamp, count|
              {x: timestamp, y: count}
            end
          }
        end
      end.compact.to_json

      @read_queries_json = queries.map do |query|
        if query[:data] && READ_QUERIES.include?(query[:query])
          {
            name: query[:query],
            data: query[:data].map do |timestamp, count|
              {x: timestamp, y: count}
            end
          }
        end
      end.compact.to_json

      performance =  Metrics.query_performance(@granularity_key, @from, @to)
      @performance_json = performance[:count].zip(performance[:duration]).map do |count, duration|
        timestamp = count.first
        count = count.last
        duration = duration.last
        {x: timestamp, y: count > 0 ? (duration.to_f / count.to_f / 10.0).round(2) : 0}
      end.compact.to_json


      @read_duration_json = queries.zip(duration).map do |counts, durations|
        if counts[:query] == durations[:query] && READ_QUERIES.include?(counts[:query])
          {
            name: counts[:query],
            data: counts[:data].zip(durations[:data]).map do |count, duration|
              timestamp = count.first
              count = count.last
              duration = duration.last
              {x: timestamp, y: count > 0 ? (duration.to_f / count.to_f / 10.0).round(2) : 0}
            end
          }
        end
      end.compact.to_json

      @write_duration_json = queries.zip(duration).map do |counts, durations|
        if counts[:query] == durations[:query] && WRITE_QUERIES.include?(counts[:query])
          {
            name: counts[:query],
            data: counts[:data].zip(durations[:data]).map do |count, duration|
              timestamp = count.first
              count = count.last
              duration = duration.last
              {x: timestamp, y: count > 0 ? (duration.to_f / count.to_f / 10.0).round(2) : 0}
            end
          }
        end
      end.compact.to_json
    end

  end
end
