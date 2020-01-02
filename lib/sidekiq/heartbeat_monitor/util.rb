
module Sidekiq
  module HeartbeatMonitor
    module Util

      def format_time_str(sec_backed_up)
        hours = (sec_backed_up - (sec_backed_up % 3600)) / 3600
        minutes = (sec_backed_up - (sec_backed_up % 60)) / 60
        seconds = sec_backed_up % 60

        nice_backed_up_str = "#{seconds} sec"
        nice_backed_up_str = "#{minutes} min #{nice_backed_up_str}" if minutes > 0
        nice_backed_up_str = "#{hours} hr #{nice_backed_up_str}" if hours > 0

        nice_backed_up_str
      end

    end
  end
end
