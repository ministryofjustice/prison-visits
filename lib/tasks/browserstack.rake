namespace :browserstack do
  task :browsers do
    YAML.load_file('config/browsers.json').each_with_index do |b, i|
      puts "#{i}. #{b.values.join(' ')}"
    end
  end

  task :run, :browser do |t, args|
    begin
      unless ENV['BS_USERNAME'] && ENV['BS_PASSWORD']
        puts "The BS_USERNAME and BS_PASSWORD environment variables must be set prior to running this task."
        exit
      end

      browsers = YAML.load_file('config/browsers.json')
      nodes = 2
      
      # Fire up a test server in a background process.
      app_pid = fork do
        exec("rails s -e test")# 2>&1 > /dev/null")
      end

      browsers = [browsers[args[:browser].to_i]] if args[:browser]

      # Fire up a tunnel in the background and wait until it is ready.
      r, w = IO.pipe
      pid = spawn("java -jar vendor/BrowserStackTunnel.jar -skipCheck #{ENV['BS_PASSWORD']} localhost,3000,0", out: w)
      while content = r.readline
        break if content == "Press Ctrl-C to exit\n"
      end
      
      Parallel.map(browsers, in_processes: nodes) do |browser|
        # We're in a subprocess here - set the environment variable BS_BROWSER to the desired browser configuration.
        ENV['BS_BROWSER'] = browser.to_json
 
        # Fire up a subprocess with the actual tests.
        system("rake spec:features")
      end
    ensure
      # Regardless of what happens, terminate everything.

      Process.kill("HUP", pid)
      Process.kill("HUP", app_pid)
      Process.waitall
    end
  end
end
