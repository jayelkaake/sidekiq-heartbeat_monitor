module Sidekiq
  module HeartbeatMonitor
    class Worker

      include Sidekiq::Worker
      include Sidekiq::HeartbeatMonitor::Util
      sidekiq_options retry: 0

      ##
      # Runs every x seconds and ensures that the time between jobs is consistent and
      # @param queue_name [String] Name of the queue that this heartbeat is running on.
      def perform(queue_name)
        Sidekiq.redis do |redis|
          q = Sidekiq::Queue.all.find{ |q| q.name.to_s == queue_name.to_s }
          queue_config = Sidekiq::HeartbeatMonitor.config(q)

          key = "Sidekiq:HeartbeatMonitor:Worker-#{queue_name}.enqueued_at"
          enqueued_at = redis.get(key).to_i

          return if enqueued_at < 1577997505 # Enqueued before Jan 2, 2020 when this code was written

          time_since_enqueued = Time.now.to_i - enqueued_at

          if time_since_enqueued > queue_config.max_heartbeat_delay
            queue_config.send_slowed_down_alert!("⚠️ _#{queue_name}_ queue took #{format_time_str(time_since_enqueued)} to reach job.", q)
          end

          redis.del(key)
        end
      end


    end
  end
end
