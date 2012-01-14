#!/usr/bin/env ruby

# In production and staging, starts 3 workers. 

require File.expand_path('../../config/environment',  __FILE__)
require 'daemon_spawn'

class StalkerWorkerDaemon < DaemonSpawn::Base
  def start(args)
    exec "stalk config/stalker_jobs.rb"
  end
  def stop
   
  end
end

StalkerWorkerDaemon.spawn!({
  processes: (Rails.env.development? ? 2 : 3),
  log_file: Rails.root.join("log", "stalker_worker.log").to_s, # to_s needed here
  sync_log: true,
  working_dir: Rails.root,
  singleton: true
})