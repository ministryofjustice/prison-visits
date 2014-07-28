namespace :static_pages do
  desc "Generates static pages"
  task generate: 'assets:precompile' do
    pages = {
      'static/404' => '404.html',
      'static/500' => '500.html',
      'static/503' => '503.html',
      '/cookies' => 'cookies.html',
      '/cookies-disabled' => 'cookies-disabled.html',
      '/terms-and-conditions' => 'terms-and-conditions.html',
      '/unsubscribe' => 'unsubscribe.html'
    }

    # Silence a warning for the session key not being set.
    Rails.application.config.secret_key_base = SecureRandom.hex
    app = ActionDispatch::Integration::Session.new(Rails.application)

    pages.each do |route, output|
      puts "Generating #{output}..."
      outpath = File.join ([Rails.root, 'public', output])
      resp = app.get(route)
      if resp == 200
        File.delete(outpath) unless not File.exists?(outpath)
        File.open(outpath, 'w') do |f|
          f.write(app.response.body)
        end
      else
        puts "Error generating #{output}!"
      end
    end
  end
end
