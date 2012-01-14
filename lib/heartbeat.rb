#!/usr/bin/env ruby

require File.expand_path('../../config/environment',  __FILE__)
require 'daemon_spawn'
require "fileutils"

module Heartbeat
  
  # Generic class for repeated tasks without clock drifting.
  # This was found at
  # http://soohwan.blogspot.com/2011/02/ruby-periodic-process.html
  class Service  
    def initialize  
      @interval = 1.0  
      @start_time = Time.now   
    end  
    def start   
      # Update the start-time  
      @start_time = Time.now   
      # run loop  
      loop do  
        t_start = Time.now  
        # process the job  
        process  
        elapsed = Time.now - t_start  
        if elapsed > @interval  
          puts "Error: Job is bigger than Interval.. #{elapsed}"  
        end  
        # apply some compensation.   
        compensation = (Time.now - @start_time) % @interval  
        sleep(@interval - compensation)  
      end  
    end  
    def process  
      raise NotImplementedError  
    end  
  end
  
  class AuctionEnder < Service
    def process # how many auctions ended this cycle
      finished = Auction.inactive.where(finished: false).update_all(finished: true)
      Rails.cache.increment("finished", finished)
    end
    
    def recover!(period)
      t = Time.now
      puts "#{t} Entered recovery mode"
      t_0 = t - period
      auctions = Auction.where(ending_at: t_0..t)    
      if auctions.size > 0
        src = Rails.root.join("public", "watchdog-recovery.html")
        dest = Rails.root.join("public", "system", "maintenance.html")
        FileUtils.cp(src, dest)
        auctions.each do |a|
          a.ending_at += 600 # 10 minutes
          a.save
        end
        Rails.cache.increment("bids") # TODO: better cache key
        sleep(1)
        FileUtils.rm(dest)
      end
      puts "#{Time.now} #{auctions.size} auction/s reset"
    end
  end
  
  class Runner < DaemonSpawn::Base
    def start(args)
      a = AuctionEnder.new
      if args[0] == "recovery"
        a.recover!(args[1].to_i)
      end
      a.start
    end
    
    def stop
      puts "#{Time.now} Manually stopped"
    end
  end
end

Heartbeat::Runner.spawn!({
  application: "Heartbeat",
  log_file: Rails.root.join("log", "heartbeat.log"),
  pid_file: Rails.root.join("tmp", "pids", "heartbeat.pid"),
  working_dir: Rails.root,
  singleton: true
})