require_dependency "peekarails/application_controller"

module Peekarails
  class DashboardController < ApplicationController

    def show
      @action_controller = ActionControllerInstrument.new

      @total_minutes_json = @action_controller.total(:minutes).map do |timestamp, count|
        {x: timestamp.to_i, y: count.to_i}
      end.to_json
    end
  end
end
