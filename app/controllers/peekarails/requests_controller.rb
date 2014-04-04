require_dependency "peekarails/base_controller"

module Peekarails
  class RequestsController < BaseController

    def index
      actions = Metrics.actions

      if params[:action] && actions.include?(params[:action_name])
        @action = params[:action_name]
      else
        @action = 'total'
      end

      count = Metrics.count(@granularity_key, @from, @to, @action)
      duration = Metrics.duration(@granularity_key, @from, @to, @action)
      view_duration = Metrics.view_duration(@granularity_key, @from, @to, @action)
      db_duration = Metrics.db_duration(@granularity_key, @from, @to, @action)

      @minutes_json = count.map do |timestamp, count|
        {x: timestamp.to_i, y: count.to_i}
      end.to_json

      if count.length > duration.length
        count = count.take(duration.length)
      end

      @duration_json = count.zip(duration).map do |count, duration|
        timestamp = count.first
        count = count.last
        duration = duration.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json

      @db_duration = count.zip(db_duration).map do |count, duration|
        timestamp = count.first
        count = count.last
        duration = duration.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json
      @view_duration = count.zip(view_duration).map do |count, duration|
        timestamp = count.first
        count = count.last
        duration = duration.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json
      @other_duration = count.zip(duration, view_duration, db_duration).map do |count, total, view, db|
        timestamp = count.first
        count = count.last
        duration = total.last - view.last - db.last
        {x: timestamp, y: count > 0 ? duration / count : 0}
      end.to_json

      now = Time.now.to_i
      status = Metrics.status(@granularity_key, @from, @to, @action)

      @status_json = status.map do |status|
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
      @total_requests = 0
      actions.each do |action|
        counts = Metrics.count(@granularity_key, @from, @to, action)

        if counts
          total = 0
          counts.each do |timestamp, count|
            total += count.to_i
          end
          @total_requests += total
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
