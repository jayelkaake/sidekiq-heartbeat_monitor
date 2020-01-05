namespace :sidekiq do
  namespace :heartbeat_monitor do

    desc "Install sidekiq heartbeat monitor gem heartbeat cron task."
    task :install => :environment do
      Sidekiq::HeartbeatMonitor::Config.install_cron_job!(output: true)
    end
  end
end
