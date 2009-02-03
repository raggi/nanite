if RUBY_PLATFORM =~ /mswin|mingw/
  # Sorry, but i'm so fed up of re-writing this :-P
  def File.epjf(*paths)
    p = File.expand_path(File.join(*paths))
    p.gsub! File::SEPARATOR, File::ALT_SEPARATOR if File::ALT_SEPARATOR
    p
  end

  working_dir  = File.epjf(File.dirname(__FILE__), '..', 'examples', 'simpleagent')
  service_name = 'nanite-agent'

  namespace :service do

    sc = Proc.new do |command, args|
      command = "sc #{command} #{service_name} #{args}"
      puts command
      system command
    end

    desc "install the service"
    task :install => :service do |t|
      puts "Installing nanite service for dir #{working_dir}"
      bin_path = File.epjf(File.dirname(__FILE__), '..', 'bin', 'nanite')
      rb = Gem.ruby.sub('ruby.exe', 'rubyw.exe')
      sc[:create, %(binPath= "#{rb} -C '#{working_dir}' -rubygems '#{bin_path}' --daemonize" start= auto)]
      sc[:start]
    end

    desc "remove the service"
    task :uninstall => :stop do
      sc[:delete]
    end

    desc "stop then start the service"
    task :restart => %w(stop start)

    desc "start service"
    task :start => :service do
      sc[:start]
    end
    desc "stop service"
    task :stop  => :service do
      sc[:stop]
    end
  end

  desc "service[working_dir, service_name] setup parameters for installation"
  task :service, :working_dir, :service_name do |t, args|
    working_dir  = args[:working_dir]  || ENV['working_dir']  || working_dir
    service_name = args[:service_name] || ENV['service_name'] || service_name
  end
end