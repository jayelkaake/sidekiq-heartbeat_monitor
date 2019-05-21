
require 'sidekiq-heartbeat_monitor/version'
require 'sidekiq-heartbeat_monitor/config'
require 'sidekiq-heartbeat_monitor/scheduler'
require 'sidekiq-heartbeat_monitor/worker'

module Sidekiq
  module HeartbeatMonitor
    def self.configure(*args, &block)
      Config.configure(*args, &block)
    end
  end
end

