module Sidekiq
  module HeartbeatMonitor
    class Worker

      include Sidekiq::Worker
      sidekiq_options retry: 0

      ##
      # Runs every x seconds and ensures that the time between jobs is consistent and
      # @param queue_name [String] Name of the queue that this heartbeat is running on.
      def perform(queue_name, secs_between_beats = 15)
        current_run_at = Time.now.utc.to_i
        last_run_at = $redis.get("Sidekiq/HeartbeatMonitor/Worker/#{queue_name}.last_run_at").to_i

        if last_run_at > 0
          time_since_last_run = current_run_at - last_run_at
          if time_since_last_run > (5.minutes + secs_between_beats)
            sec_backed_up = time_since_last_run - secs_between_beats

            send_server_alert("⚠️ queue #{queue_name} took > #{sec_backed_up}s to reach job.", queue_name)
          end
        end

        $redis.set("Sidekiq/HeartbeatMonitor/Worker/#{queue_name}.last_run_at", current_run_at, ex: 1.hour)
      end

      ##
      # @param msg [String] Message to post
      # @param queue_name [String] Queue we're concerned with
      def send_server_alert(msg, queue_name)
        Sidekiq::HeartbeatMonitor::Config.send_slowed_down_alert(msg, queue_name)

        true
      end


    end
  end
end
