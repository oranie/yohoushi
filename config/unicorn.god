# https://gist.github.com/nragaz/472092
# http://unicorn.bogomips.org/SIGNALS.html
RAILS_ENV     ||= ENV['RAILS_ENV'] ||= 'development'
RAILS_ROOT    ||= ENV['RAILS_ROOT'] = File.expand_path('../..', __FILE__)
PID_DIR       ||= "#{RAILS_ROOT}/log"
BIN_PATH      ||= "#{RAILS_ROOT}/bin"

God.watch do |w|
  w.name = "unicorn"
  w.group = "yohoushi"
  w.interval = 30.seconds # default
  
  # unicorn needs to be run from the rails root
  w.start = "cd #{RAILS_ROOT} && #{BIN_PATH}/unicorn -c #{RAILS_ROOT}/config/unicorn.conf -E #{RAILS_ENV} -D"
 
  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat #{PID_DIR}/unicorn.pid`"
 
  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat #{PID_DIR}/unicorn.pid`"
 
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "#{PID_DIR}/unicorn.pid"
 
  # w.uid = 'rails'
  # w.gid = 'rails'
 
  w.behavior(:clean_pid_file)
 
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
 
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
 
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
 
  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
