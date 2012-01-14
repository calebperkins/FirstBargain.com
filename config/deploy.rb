$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"

require 'bundler/capistrano'

#require 'config/boot'
#require 'hoptoad_notifier/capistrano'

set :application, "First Bargain"
set :scm, :git
set :repository, "git@github.com:expedientshopping/firstbargain.git"
set :branch, CLI.ui.ask("What branch? ")
set :user, "deploy"
set :deploy_via, :remote_cache
set :scm_auth_cache, true
set :use_sudo, false
ssh_options[:forward_agent] = true
set :rvm_ruby_string, '1.9.2'
set :rvm_type, :user

desc "Run tasks on staging"
task :staging do
  server "SECRET.blueboxgrid.com", :web, :app, :db, :primary => true
  set :rails_env, 'staging'
  set :deploy_to, "/home/deploy/staging"
  set :password, "SECRET"
end

desc "Run tasks in production environment"
task :production do
  set :rails_env, 'production'
  server "SECRET2.blueboxgrid.com", :web, :app, :db, :primary => true
  set :deploy_to, "/home/deploy/firstbargain"
  after "deploy", "deploy:push_deploy_tag"
  after "deploy:symlink", "deploy:update_crontab"
end

namespace :deploy do
  before "deploy:update",     "disable_web"
  after "deploy:update",      "deploy:migrate"
  after "deploy:restart",     "deploy:web:enable"
  after "deploy:update",      "deploy:cleanup"
  after "deploy:symlink",      "deploy:jammit"
  after "deploy:stop",        "daemons:stop"
  after "deploy:start",       "daemons:start"
  after "deploy:restart",     "daemons:restart"
  
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  desc "Run Jammit"
  task :jammit do
    run "cd #{deploy_to}/current && jammit"
  end
  
  desc "Set Git tags"
  task :push_deploy_tag do
    user = `git config --get user.name`.chomp
    email = `git config --get user.email`.chomp
    puts `git tag #{rails_env}_#{release_name} #{current_revision} -m "Deployed by #{user} <#{email}>"`
    puts `git push --tags origin`
  end
  
  desc "Update the crontab file"  
  task :update_crontab, :roles => :db do  
    run "cd #{release_path} && whenever --update-crontab firstbargain"  
  end
end

namespace :daemons do
  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

  desc "Start Stalker workers and Heartbeat"
  task :start, :roles => :app do
    run "cd #{current_path};#{rails_env} lib/stalker_worker.rb start"
    run "cd #{current_path};#{rails_env} lib/heartbeat.rb start"
  end

  desc "Stop Stalker workers and Heartbeat"
  task :stop, :roles => :app do
    run "cd #{current_path};#{rails_env} lib/stalker_worker.rb stop"
    run "cd #{current_path};#{rails_env} lib/heartbeat.rb stop"
  end

  desc "Restart Stalker workers and Heartbeat"
  task :restart, :roles => :app do
    run "cd #{current_path};#{rails_env} lib/stalker_worker.rb restart"
    run "cd #{current_path};#{rails_env} lib/heartbeat.rb restart"
  end
end

desc "Put up the maintenance page"
task :disable_web, :roles => :web do
  require 'haml'
  template = File.read 'app/views/layouts/maintenance.html.haml'
  page = Haml::Engine.new(template).render
  put page, "#{shared_path}/system/maintenance.html", :mode => 0644
end
