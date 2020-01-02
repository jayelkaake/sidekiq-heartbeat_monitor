module Sidekiq
  module HeartbeatMonitor
    ##
    # Used for testing purposes to ensure that the system is working properly.
    class TestWorker

      include Sidekiq::Worker

      sidekiq_options retry: 0

      def perform(wait_time = 1.second)
        puts "Internal test worker started and will continue for the next #{wait_time} seconds." if wait_time > 3.seconds

        sleep(wait_time)

        puts "Internal test worker finished after #{wait_time} seconds." if wait_time > 3.seconds
      end

    end
  end
end
