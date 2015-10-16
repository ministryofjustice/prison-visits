Rails.configuration.prisons = []

Dir["config/prisons/*.yml"].each { |file|
  Prison.create(YAML.load_file(file))
}
