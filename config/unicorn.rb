# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

listen ENV['LISTEN_ON']

timeout 30
preload_app true

GC.respond_to?(:copy_on_write_friedly=) && GC.copy_on_write_friedly = true

check_client_connection false

before_fork do |server, worker|
  # Signal.trap 'TERM' do
  #   puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
  #   Process.kill 'QUIT', Process.pid
  # end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

    old_pid = "#{server.config[:pid]}.oldbin"
    if old_pid != server.pid
      begin
        sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
        Process.kill sig, File.read(old_pid).to_i
      rescue Errno::ENOENT, Errno::ESRCH
      end
    end
end

after_fork do |server, worker|
  # Signal.trap 'TERM' do
  #   puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  # end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
