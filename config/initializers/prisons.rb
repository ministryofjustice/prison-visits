Rails.configuration.prisons = YAML.load_file(
  ENV.fetch('PRISON_DATA_FILE', Rails.configuration.prison_data_source)
).map{ |p| Prison.new(p) }.sort_by(&:name)
