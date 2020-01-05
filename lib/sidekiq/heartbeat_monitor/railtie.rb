require 'sidekiq/heartbeat_monitor'
require 'rails'

module Sidekiq
  module HeartbeatMonitor
    class Railtie < ::Rails::Railtie
      railtie_name :sidekiq_heartbeat_monitor

      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end
