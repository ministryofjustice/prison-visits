Rails.configuration.prisons = []

Dir["config/prisons/*.yml"].each { |file|
  prison = YAML.load_file(file)
  if ENV['GSI_SMTP_HOSTNAME'] == 'maildrop.dsd.io' || Rails.env.test?
    prison['email'] = "pvb.#{prison['nomis_id']}@maildrop.dsd.io"
  end
  Prison.create(prison)
}
