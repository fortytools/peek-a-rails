require 'bootstrap-sass'
require 'rickshaw_rails'
require 'jquery-ui-rails'

require 'peekarails/rack'

module Peekarails
  class Engine < ::Rails::Engine
    isolate_namespace Peekarails

    config.app_middleware.use Peekarails::Rack

    initializer "subscribe to notifications" do
      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
        event = ActiveSupport::Notifications::Event.new *args

        Thread.current[:peekarails_context][:action] =
          "#{event.payload[:controller]}##{event.payload[:action]}"

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
