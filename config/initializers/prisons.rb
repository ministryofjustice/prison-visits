Rails.configuration.prisons = []

Dir["config/prisons/*.yml"].each { |file|
  prison = YAML.load_file(file)
  unless Rails.env.production?
    prison['email'] = "pvb.#{prison['nomis_id']}@maildrop.dsd.io"
  end
  Prison.create(prison)
}
