require "sidekiq"
require 'sidekiq/heartbeat_monitor/version'
require 'sidekiq/heartbeat_monitor/config'
require 'sidekiq/heartbeat_monitor/util'
require 'sidekiq/heartbeat_monitor/scheduler'
require 'sidekiq/heartbeat_monitor/worker'
require 'sidekiq/heartbeat_monitor/test_worker'

require 'sidekiq/heartbeat_monitor/railtie' if defined?(Rails)


module Sidekiq
  module HeartbeatMonitor
    def self.configure(options = {})
      options = options.symbolize_keys
      global_options = options.except(:queues)

      @global_config = Config.new(**global_options)

      @queue_config = {}
      options[:queues].to_a.each do |queue_name, queue_options|
        @queue_config[queue_name.to_s] = Config.new(**global_options.deep_merge(queue_options))
      end
    end

    def self.config(queue = nil)
      return @global_config if queue.blank?

      queue_name = queue.is_a?(String) || queue.is_a?(Symbol) ? queue.to_s : queue.name.to_s
      @queue_config[queue_name] || @global_config
    end

    def self.send_test!(queue_name = nil)
      test_queue = Sidekiq::Queue.new(queue_name || 'test')

      send_backed_up_alert("Test backed up alert!", test_queue)
      send_slowed_down_alert("Test slowed down alert!", test_queue)
    end

  end
end

