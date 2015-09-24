namespace :browserstack do
  task :browsers do
    YAML.load_file('config/browsers.json').each_with_index do |b, i|
      puts "#{i}. #{b.values.join(' ')}"
    end
  end

  task :run, :browser do |_t, args|
    begin
      unless ENV['BS_USERNAME'] && ENV['BS_PASSWORD']
        puts "The BS_USERNAME and BS_PASSWORD environment variables must be set prior to running this task."
        exit
      end

      browsers = YAML.load_file('config/browsers.json')
      nodes = 5
      exitstatus = 255

      # Fire up a test server in a background process.
      app_pid = spawn("rails s -e test 2>&1 > rails_browserstack.log")

      browsers = [browsers[args[:browser].to_i]] if args[:browser]

      # Fire up a tunnel in the background and wait until it is ready.
      r, w = IO.pipe
      pid = spawn("java -jar vendor/BrowserStackTunnel.jar -skipCheck #{ENV['BS_PASSWORD']} localhost,3000,0", out: w)
      content = r.readline

      loop do
        content = r.readline
        break if content.nil? || content == "Press Ctrl-C to exit\n"
      end

      at_exit do
        Process.kill("TERM", pid)
        Process.kill("TERM", app_pid)
        Process.waitall
      end

      results = Parallel.map(browsers, in_processes: nodes) do |browser|
        # We're in a subprocess here - set the environment variable BS_BROWSER to the desired browser configuration.
        ENV['BS_BROWSER'] = browser.to_json

        test_label = ['os', 'os_version', 'browser', 'browser_version'].map(&:browser).join('_')

        system("rspec spec/features --format RspecJunitFormatter --out '#{test_label}.xml'")
      end
      exitstatus = results.count(&:'!e')
    rescue StandardError => e
      pp e
    ensure
      exit(exitstatus)
    end
  end
end

# Ugly hack to prevent running features when browserstack environment variables are defined.
RSpec::Core::RakeTask.class_eval do
  def files_to_run
    FileList[pattern].reject{ |f| f.include?('feature') }.sort.map { |f| shellescape(f) }
  end
end if ENV['BS_USERNAME']
