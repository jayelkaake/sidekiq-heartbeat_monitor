
module Sidekiq
  module HeartbeatMonitor
    module Util

      ##
      # Nicely formats a seconds string.
      # Example 1: 100.seconds => "1 min 40 sec"
      # Example 2: 13.hours => "13 hr"
      # 
      # @param total_seconds [String]  Total number of seconds to format nicely.
      # @return [String] A string representation of the time.
      def format_time_str(total_seconds)
        remaining_sec = total_seconds

        hours = (remaining_sec - (remaining_sec % 3600)) / 3600
        remaining_sec -= hours * 3600

        minutes = (remaining_sec - (remaining_sec % 60)) / 60
        remaining_sec -= minutes * 60

        seconds = remaining_sec

        nice_backed_up_str = "#{seconds} sec" if seconds > 0 || (minutes < 1 && hours < 1)
        nice_backed_up_str = "#{minutes} min #{nice_backed_up_str}" if minutes > 0 || (seconds > 0 && hours > 0)
        nice_backed_up_str = "#{hours} hr #{nice_backed_up_str}" if hours > 0

        nice_backed_up_str.strip
      end

    end
  end
end
