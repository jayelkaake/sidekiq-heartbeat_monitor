require 'sidekiq/cron/job'
module Sidekiq
  module HeartbeatMonitor
    class Config
      attr_accessor :max_queue_size, :max_heartbeat_delay

      ##
      # @param max_queue_size [Integer]       The maximum queue size (default: 5000 or SIDEKIQ_MONITOR_MAX_QUEUE_SIZE environment value)
      # @param on_backed_up [Proc|Array<Proc>]        On backed up run this or these procs
      # @param on_slowed_down [Proc|Array<Proc>]      On slowed down run this or these procs
      # @param dont_repeat_for [Integer]     The don't repeat for (optional, default: 5.minutes)
      # @param slack_notifier_url [String]  The slack notifier url (optional)
      # @param max_heartbeat_delay [Integer] The maximum heartbeat delay (default: 5 minute, max: 5 days)
      def initialize(max_queue_size: nil, on_backed_up: nil, on_slowed_down: nil, dont_repeat_for: nil, slack_notifier_url: nil, max_heartbeat_delay: nil)
        @max_queue_size = max_queue_size ||  ENV.fetch('SIDEKIQ_MONITOR_MAX_QUEUE_SIZE', 5000).to_i

        @dont_repeat_for = dont_repeat_for unless dont_repeat_for.nil?

        @max_heartbeat_delay = max_heartbeat_delay || 5.minutes

        @on_backed_up = (on_backed_up.is_a?(Enumerable) ? on_backed_up : [on_backed_up]) unless on_backed_up.nil?
        @on_slowed_down = (on_slowed_down.is_a?(Enumerable) ? on_slowed_down : [on_slowed_down]) unless on_slowed_down.nil?

        setup_slack_notifier!(slack_notifier_url) if slack_notifier_url.present?

        install_cron_job!
      end

      def send_test!
        test_queue = Sidekiq::Queue.new('test')
        send_backed_up_alert("Test backed up alert!", test_queue)
        send_slowed_down_alert("Test slowed down alert!", test_queue)
      end

      def send_backed_up_alert!(message, q)
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

      def send_slowed_down_alert!(message, q)
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

      private

      def setup_slack_notifier!(slack_notifier_url)
        @notifier = Slack::Notifier.new(slack_notifier_url)

        slack_notifier_callback = [-> (msg, queue) { @notifier.ping(msg) }]

        @on_backed_up = @on_backed_up.to_a + slack_notifier_callback
        @on_slowed_down = @on_slowed_down.to_a + slack_notifier_callback
      end

      def install_cron_job!
        job = Sidekiq::Cron::Job.find("sidekiq_monitor")

        target_job = Sidekiq::Cron::Job.new(
          name: 'sidekiq_monitor', 
          cron: '* * * * *', 
          klass: Sidekiq::HeartbeatMonitor::Scheduler
        )

        if job.present?
          if job.cron != target_job.cron && job.klass.to_s != target_job.klass
            job.destroy
            target_job.save
          end
        else
          target_job.save
        end
      end

    end
  end
end
