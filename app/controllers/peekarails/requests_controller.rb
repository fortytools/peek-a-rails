require_dependency "peekarails/application_controller"

module Peekarails
  class RequestsController < ApplicationController

    def index
      count = Metrics.total_count(@granularity_key, @from, @to)
      duration = Metrics.total_duration(@granularity_key, @from, @to)
      view_duration = Metrics.total_view_duration(@granularity_key, @from, @to)
      db_duration = Metrics.total_db_duration(@granularity_key, @from, @to)

      @total_minutes_json = count.map do |timestamp, count|
        {x: timestamp.to_i, y: count.to_i}
      end.to_json

      if count.length > duration.length
        count = count.take(duration.length)
      end

      @total_duration_json = count.zip(duration).map do |count, duration|
        timestamp = count.first
        count = count.last
        duration = duration.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json

      @total_db_duration = count.zip(db_duration).map do |count, duration|
        timestamp = count.first
        count = count.last
        duration = duration.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json
      @total_view_duration = count.zip(view_duration).map do |count, duration|
        timestamp = count.first
        count = count.last
        duration = duration.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json
      @total_other_duration = count.zip(duration, view_duration, db_duration).map do |count, total, view, db|
        timestamp = count.first
        count = count.last
        duration = total.last - view.last - db.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json

      now = Time.now.to_i
      total_status = Metrics.total_status(@granularity_key, @from, @to)

      @total_status_json = total_status.map do |status|
        if status[:data]
          {
            name: status[:status],
            data: status[:data].map do |timestamp, count|
              {x: timestamp, y: count}
            end
          }
        end
      end.compact.to_json

      @actions = []
      Metrics.actions.each do |action|
        counts = Metrics.count(action, @granularity_key)

        if counts
          total = 0
          counts.each do |timestamp, count|
            total += count.to_i
          end
          action_info = { name: action, total: total}
          @actions << action_info
        end
      end

      @actions = @actions.sort do |left, right|
        right[:total] <=> left[:total]
      end
    end

  end
end
