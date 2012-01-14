# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

## Email daily report at 12:01 am (Linux time zone, which is PT)
every 1.days, :at => "12:01 am" do
  runner "StaffMailer.daily_activity_report.deliver"
end

## Email weekly report at 12:01 am on Sunday (Linux time zone, which is PT)
every :sunday, :at => "12:01 am" do
  runner "StaffMailer.weekly_activity_report.deliver"
end

## Sync Mailchimp at 12:03 AM PT
every 1.days, :at => "12:03 am" do
  runner "Account.sync_mailchimp"
end

## Expire Redis bid bot jobs cache
every 1.days, :at => "1:00 am" do 
  runner "Auction.expire_redis_job_cache_for_last_24_hours"
end
  
