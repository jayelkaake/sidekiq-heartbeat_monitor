require 'sidekiq/cron/job'
module Sidekiq
  module HeartbeatMonitor
    class Config
      class << self
        def configure(max_queue_size: nil, on_backed_up: nil, on_slowed_down: nil, dont_repeat_for: nil, slack_notifier_url: nil)
          @max_queue_size = max_queue_size unless max_queue_size.nil?

          @dont_repeat_for = dont_repeat_for unless dont_repeat_for.nil?

          @on_backed_up = (on_backed_up.is_a?(Enumerable) ? on_backed_up : [on_backed_up]) unless on_backed_up.nil?
          @on_slowed_down = (on_slowed_down.is_a?(Enumerable) ? on_slowed_down : [on_slowed_down]) unless on_slowed_down.nil?

          if slack_notifier_url.present?
            @notifier = Slack::Notifier.new(slack_notifier_url)

            slack_notifier_callback = [-> (msg, queue) { @notifier.ping(msg) }]

            @on_backed_up = @on_backed_up.to_a + slack_notifier_callback
            @on_slowed_down = @on_slowed_down.to_a + slack_notifier_callback
          end

          unless Sidekiq::Cron::Job.find("sidekiq_monitor").present?
            Sidekiq::Cron::Job.create(
              name: 'sidekiq_monitor', 
              cron: '*/15 * * * * *', 
              klass: Sidekiq::HeartbeatMonitor::Scheduler
            )
          end
        end

        def send_test!
          test_queue = Sidekiq::Queue.new('test')
          send_backed_up_alert("Test backed up alert!", test_queue)
          send_slowed_down_alert("Test slowed down alert!", test_queue)
        end

        def send_backed_up_alert(message, q)
          if @on_backed_up.blank?
            puts ("WARNING: No 'on_backed_up' callback defined for sidekiq-heartbeat_monitor but one of the queues are backed up: #{message}")
            return
          end

          if @dont_repeat_for.nil?
            @on_backed_up.to_a.each { |alert| alert.call(message, q) }
          else
            DontRepeatFor.new(@dont_repeat_for, "Sidekiq/HeartbeatMonitor/#{q.name}/send_backed_up_alert") do
              @on_backed_up.to_a.each { |alert| alert.call(message, q) }
            end
          end
        end

        def send_slowed_down_alert(message, q)
          if @on_slowed_down.blank?
            puts ("WARNING: No 'on_slowed_down' callback defined for sidekiq-heartbeat_monitor but one of the queues are backed up: #{message}")
            return
          end

          if @dont_repeat_for.nil?
            @on_slowed_down.to_a.each { |alert| alert.call(message, q) }
          else
            DontRepeatFor.new(@dont_repeat_for, "Sidekiq/HeartbeatMonitor/#{q.name}/send_slowed_down_alert") do
              @on_slowed_down.to_a.each { |alert| alert.call(message, q) }
            end
          end
        end

        def max_queue_size
          @max_queue_size || ENV.fetch('SIDEKIQ_MONITOR_MAX_QUEUE_SIZE', 5000).to_i
        end
      end
    end
  end
end
