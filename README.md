# Sidekiq Heartbeat Montior Gem

This gem adds 2 things:
1. A lightweight heartbeat task that runs every few minutes and alerts if it takes longer than a few seconds to start.
2. A scheduler task that periodically checks the size of each sidekiq queue to ensure no queues are backed up.

**Table of Contents**
* [Installation](#installation)
* [Configuration](#configuration)
* [Other Things](#Other_Things)

# Installation
Add this line to your application's Gemfile:
```ruby
gem 'sidekiq-heartbeat_monitor'
```
And then execute:
    $ bundle
Or install it yourself as:
    $ gem install sidekiq-heartbeat_monitor

**Configuration is required - see the Configuration section below**

### Requirements
1. [Dont Repeat For Gem](https://www.github.com/jayelkaake/dont_repeat_for) - To allow you to only send notifications every so often.
2. Redis
3. (optional) [SlackNotifier](https://github.com/stevenosloan/slack-notifier) - If you're using slack notifications then this is needed.

# Configuration
### STEP 1. Create slack webhook
To add a webhook to your slack account, go to: https://api.slack.com/incoming-webhooks
Make note of the URL or add it to your environment and note the name.

### STEP 2. Add Initializer

To configure with a simple slack webhook notification URL, simply specify the notification URL in the "slack_notifier_url" attribute.

##### 2. Option 1 - Simple notification
```ruby
# config/initializers/sidekiq/hearbeat_monitor.rb
Sidekiq::HeartbeatMonitor.configure(slack_notifier_url: ENV['SLACK_WEBHOOK_URL'])
```

##### 2. Option 2 - Dont Repeat For
```ruby
# config/initializers/sidekiq/hearbeat_monitor.rb
Sidekiq::HeartbeatMonitor.configure(
    slack_notifier_url: ENV['SLACK_WEBHOOK_URL'],
    dont_repeat_for: 15.minutes # Won't repeat the notifications for the same queue more than once every 15 minutes.
)
```

##### 2. Option 2 - Custom Alert Method
```ruby
# config/initializers/sidekiq/hearbeat_monitor.rb
Sidekiq::HeartbeatMonitor.configure(
    on_backed_up: -> (msg, queue) { Rails.logger.log("Queue #{queue.name} is backed up!"); },
    on_slowed_down: -> (msg, queue) { Rails.logger.log("Queue #{queue.name} is being slow!"); },
)
```

**Note:** `on_backed_up` and `on_slowed_down` accept an array and will always add to existing callbacks (you can combine `slack_notiifer_url` with them)

### STEP 3. Schedule recurring task
If you're using sidekiq-cron, add this to your `config/scheduler.yml` file:
```yml
sidekiq_heartbeat_monitor:
  cron: "*/15 * * * * *" # Heart beat runs every 15 seconds in this case
  class: "Sidekiq::HeartbeatMonitor::Scheduler"
  queue: scheduler
```

## Testing Your Config
To test your config:
1. Open your rails console.
2. Run `Sidekiq::HeartbeatMontior.send_test!` and you should see notifications come up in your Slack (or however you have them configured). If there's something wrong it should show an error.


# Other Things
### Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/jayelkaake/sidekiq-heartbeat_monitor.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

### License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
