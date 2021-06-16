# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/heartbeat_monitor/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-heartbeat_monitor"
  spec.version       = Sidekiq::HeartbeatMonitor::VERSION
  spec.authors       = ["Jay El-Kaake"]
  spec.email         = ["najibkaake@gmail.com"]

  spec.summary       = %q{Makes it easy to monitor your sidekiq queues, especially with Slack.}
  spec.description   = %q{Easily monitor your sidekiq queus with Slack or some other notification service.}
  spec.homepage      = "https://www.github.com/jayelkaake/sidekiq-heartbeat_monitor"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 4"
  spec.add_dependency "sidekiq-cron", ">= 0.6"
  spec.add_dependency "dont_repeat_for", ">= 1"
  spec.add_dependency "slack-notifier", ">= 0.5"
  spec.add_dependency "dotenv", ">= 1.0"

  spec.add_development_dependency "rails", ">= 4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "temping", "~> 3.3"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", '~> 3.4'
  spec.add_development_dependency "sqlite3", '~> 1.3'

end
