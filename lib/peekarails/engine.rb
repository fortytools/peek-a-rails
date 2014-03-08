require 'bootstrap-sass'
require 'rickshaw_rails'
require 'jquery-ui-rails'

require 'peekarails/rack'

module Peekarails
  class Engine < ::Rails::Engine
    isolate_namespace Peekarails

    config.app_middleware.use Peekarails::Rack

    initializer "subscribe to notifications" do
      ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
        event = ActiveSupport::Notifications::Event.new *args

        context = Thread.current[:peekarails_context]

        if context && event.payload[:name] != "CACHE"
          query = event.payload[:sql].split.first
          duration = (event.duration * 10.0).round

          Peekarails::Metrics.record_query! query, duration, context
        end
      end

      ActiveSupport::Notifications.subscribe ' start_processing.action_controller' do |*args|
        event = ActiveSupport::Notifications::Event.new *args

        Thread.current[:peekarails_context][:action] =
          "#{event.payload[:controller]}##{event.payload[:action]}"
      end

      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
        event = ActiveSupport::Notifications::Event.new *args

        Thread.current[:peekarails_context][:duration] =
          event.duration.round

        if event.payload[:view_runtime]
          Thread.current[:peekarails_context][:view_duration] =
            event.payload[:view_runtime].round
        end
        if event.payload[:db_runtime]
          Thread.current[:peekarails_context][:db_duration] =
            event.payload[:db_runtime].round
        end
      end

    end
  end
end
