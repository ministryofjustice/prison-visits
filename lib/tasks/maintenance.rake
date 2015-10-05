namespace :maintenance do
  desc 'Sort prisons_data.yml alphabetically.'
  task :sort_prisons_data_yaml do
    filename = 'config/prison_data.yml'
    sorted_prisons = []

    YAML.load_file(filename).tap do |yaml|
      yaml.each do |prison|
        nn = { 'name' => prison.delete('name'),
               'nomis_id' => prison.delete('nomis_id') }
        nn = nn.merge(Hash[prison.sort])
        sorted_prisons << nn
      end
      YAML.dump(sorted_prisons, File.open(filename, 'w'))
    end
  end

  task :update_bank_holidays do
    sh(
      'curl',
      '--insecure',
      'https://www.gov.uk/bank-holidays.json',
      '--output',
      'config/bank-holidays.json'
    )
  end
end
