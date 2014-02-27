require_dependency "peekarails/application_controller"

module Peekarails
  class SystemsController < ApplicationController

    def show
      now = Time.now.to_i
      gc_runs = Metrics.gc_runs(@granularity_key, now - (@granularity[:ttl] / 2), now)

      @gc_runs_json = gc_runs.map do |gc|
        if gc[:data]
          {
            name: gc[:gc],
            data: gc[:data].map do |timestamp, count|
              {x: timestamp, y: count}
            end
          }
        end
      end.compact.to_json
    end
  end
end

