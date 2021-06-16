module Sidekiq
  module HeartbeatMonitor
    class Scheduler
      TIME_BETWEEN_HEARTBEATS = 60

      include Sidekiq::Worker
      include Sidekiq::HeartbeatMonitor::Util
      sidekiq_options retry: 0

      ##
      # Checks to see if queues are backed up by 1000 or more jobs and also schedules the heartbeat job.
      def perform
        Sidekiq.redis do |redis|
          Sidekiq::Queue.all.each do |q|
            queue_config = Sidekiq::HeartbeatMonitor.config(q)
            next if queue_config.nil?
            
            check_queue_size!(q, queue_config)

            key = "Sidekiq:HeartbeatMonitor:Worker-#{q.name}.enqueued_at"

            last_enqueued_at = redis.get(key).to_i

            if last_enqueued_at > 577997505 # Enqueued after Jan 2, 2020 when this code was written
              time_since_enqueued = Time.now.to_i - last_enqueued_at
              if (time_since_enqueued - TIME_BETWEEN_HEARTBEATS) > queue_config.max_heartbeat_delay
                queue_config.send_slowed_down_alert!("⚠️ _#{q.name}_ queue is taking longer than #{format_time_str(time_since_enqueued)} to reach jobs.", q)
              else
                next
              end
            end

            redis.set(key, Time.now.to_i, ex: 1.week)

            Sidekiq::HeartbeatMonitor::Worker.client_push(
              'class' => Sidekiq::HeartbeatMonitor::Worker, 
              'args'  => [q.name], 
              'queue' => q.name
            )
          end

        end
      end

      def check_queue_size!(q, queue_config)
        max_queue_size = queue_config.max_queue_size

        if q.size > max_queue_size
         queue_config.send_backed_up_alert!("⚠️ _#{q.name}_ queue has more than #{max_queue_size} jobs waiting to be processed. Current size is #{q.size}", q)
        end
      end

    end
  end
end
