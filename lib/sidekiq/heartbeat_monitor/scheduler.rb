module Sidekiq
  module HeartbeatMonitor
    class Scheduler
      include Sidekiq::Worker
      sidekiq_options retry: 0

      ##
      # Checks to see if queues are backed up by 1000 or more jobs and also schedules the heartbeat job.
      def perform
        Sidekiq::Queue.all.each do |q|
          check_queue_size(q, Sidekiq::HeartbeatMonitor::Config.max_queue_size)

          Sidekiq::HeartbeatMonitor::Worker.client_push('class' => self, 'args' => [q.name, 15], 'queue' => q.name)
        end
      end

      def check_queue_size(q, max_queue_size)
        if q.size > max_queue_size
          send_server_alert("⚠️ Queue #{q.name} has more than #{max_queue_size} jobs waiting to be processed. Current size is #{q.size}", q)
        end
      end

      ##
      # @param msg [String] Message to post
      # @param queue_name [Sidekiq::Queue] Queue we're concerned with
      def send_server_alert(msg, q)
        Sidekiq::HeartbeatMonitor::Config.send_backed_up_alert(msg, q)

        true
      end
    end
  end
end
