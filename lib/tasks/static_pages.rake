namespace :app do
  desc "Generates static pages"
  task static: :environment do
    pages = {
      'static/404' => '404.html',
      'static/500' => '500.html',
      'static/503' => '503.html'
    }
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
