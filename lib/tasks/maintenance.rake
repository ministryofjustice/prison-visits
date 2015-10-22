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

  # TODO: remove this once the next data structure is bedded in.
  # I am leaving it here in case we find that we need to run it
  # again before the new-format data goes live   It can be removed
  # one the branch `remove-duplicate-prison-data` has been merged
  # to master and released.
  task :extract_prisons do
    filename = 'config/prison_data.yml'

    YAML.load_file(filename).tap do |yaml|
      yaml.each do |prison|
        nn = { 'name' => prison.delete('name'),
               'nomis_id' => prison.delete('nomis_id') }
        next if nn['nomis_id'].nil?
        puts "Processing #{nn}"

        nn = nn.merge(Hash[prison.sort])

        output_file =
          "config/prisons/#{nn['nomis_id']}-#{nn['name'].parameterize}.yml"
        YAML.dump(nn, File.open(output_file, 'w'))
      end
    end
  end

  # The estate is the larger organizaiton to which a 'prison' belongs.
  # So 'wincheseter - remand only' and 'winchester - conviceted only'
  # belong to the estate 'winchester'.  This is naive helper task used to
  # quickly add an 'estate' key and value to a prison yaml record.  It does
  # not try to interpret the estate name.  You will need to check that is
  # correct now that the run is complete.
  task :add_estate_to_prison do
    Dir["config/prisons/*.yml"].each do |filename|
      YAML.load_file(filename).tap do |p|
        next unless p.key?('estate') && p['estate'].blank?

        # Preserve the name-and-nomis_id top ordering.
        nn = { 'name' => p.delete('name'),
               'nomis_id' => p.delete('nomis_id') }

        puts "Processing #{nn['name']} adding estate name."

        p['estate'] = nn['name']

        nn = nn.merge(Hash[p.sort])

        output_file =
          "config/prisons/#{nn['nomis_id']}-#{nn['name'].parameterize}.yml"
        YAML.dump(nn, File.open(output_file, 'w'))
      end
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
