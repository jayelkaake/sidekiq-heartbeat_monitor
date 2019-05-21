require "sidekiq"
require 'sidekiq/heartbeat_monitor/version'
require 'sidekiq/heartbeat_monitor/config'
require 'sidekiq/heartbeat_monitor/scheduler'
require 'sidekiq/heartbeat_monitor/worker'

module Sidekiq
  module HeartbeatMonitor
    def self.configure(*args, &block)
      Config.configure(*args, &block)
    end

    def self.send_backed_up_alert(*args, &block)
      Config.send_backed_up_alert(*args, &block)
    end

    def self.send_slowed_down_alert(*args, &block)
      Config.send_slowed_down_alert(*args, &block)
    end

    def self.send_test!
      test_queue = Sidekiq::Queue.new('test')

      send_backed_up_alert("Test backed up alert!", test_queue)
      send_slowed_down_alert("Test slowed down alert!", test_queue)
    end
  end
end

