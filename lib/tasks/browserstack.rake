namespace :browserstack do
  task :browsers do
    YAML.load_file('config/browsers.json').each_with_index do |b, i|
      puts "#{i}. #{b.values.join(' ')}"
    end
  end

  task :run, :browser do |t, args|
    require 'rspec/core'

    begin
      unless ENV['BS_USERNAME'] && ENV['BS_PASSWORD']
        puts "The BS_USERNAME and BS_PASSWORD environment variables must be set prior to running this task."
        exit
      end

      browsers = YAML.load_file('config/browsers.json')
      nodes = 2
      
      # Fire up a test server in a background process.
      app_pid = spawn("rails s -e test 2>&1 > rails_browserstack.log")

      browsers = [browsers[args[:browser].to_i]] if args[:browser]

      # Fire up a tunnel in the background and wait until it is ready.
      r, w = IO.pipe
      pid = spawn("java -jar vendor/BrowserStackTunnel.jar -skipCheck #{ENV['BS_PASSWORD']} localhost,3000,0", out: w)
      while content = r.readline
        break if content == "Press Ctrl-C to exit\n"
      end
      
      results = Parallel.map(browsers, in_processes: nodes) do |browser|
        # We're in a subprocess here - set the environment variable BS_BROWSER to the desired browser configuration.
        ENV['BS_BROWSER'] = browser.to_json
 
        [RSpec::Core::Runner.run(['spec/features'], stderr = StringIO.new, stdout = StringIO.new), stderr.string, stdout.string]
      end

      # Convey success/failure status to the parent process.
      success = true
      browsers.zip(results).each do |browser, (result, stderr, stdout)|
        puts browser
        puts stdout
        success &= result
      end
    ensure
      # Regardless of what happens, terminate everything.

      Process.kill("HUP", pid)
      Process.kill("HUP", app_pid)
      Process.waitall
      exit(success)
    end
  end
end

# Ugly hack to prevent running features when browserstack environment variables are defined.
RSpec::Core::RakeTask.class_eval do
  def files_to_run
    FileList[pattern].reject { |f| f.include?('feature') }.sort.map { |f| shellescape(f) }
  end
end if ENV['BS_USERNAME']
