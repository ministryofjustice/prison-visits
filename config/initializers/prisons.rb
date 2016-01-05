Rails.configuration.prisons = []

default = {
  slot_anomalies: {},
  slots: {},
  unbookable: []
}

Dir["config/prisons/*.yml"].each { |file|
  prison = default.merge(YAML.load_file(file))
  if ENV['GSI_SMTP_HOSTNAME'] == 'maildrop.dsd.io' || Rails.env.test?
    prison['email'] = "pvb.#{prison['nomis_id']}@maildrop.dsd.io"
  end
  Prison.create(prison)
}
