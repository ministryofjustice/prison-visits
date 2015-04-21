namespace :maintenance do
  task :sort_yaml do
    ['config/prison_data_production.yml', 'config/prison_data_staging.yml'].each do |filename|
      YAML.load_file(filename).tap do |yaml|
        yaml.each_pair do |prison, data|
          if array = data['unbookable']
            array.sort!
          end

          if hash = data['slot_anomalies']
            data['slot_anomalies'] = Hash[hash.to_a.sort]
          end
        end
        YAML.dump(yaml, File.open(filename, 'w'))
      end
    end
  end

  task :update_bank_holidays do
    `curl -k https://www.gov.uk/bank-holidays.json -o config/bank-holidays.json`
  end
end
