Rails.application.config.filter_parameters += [
  :password,
  :first_name,
  :last_name,
  :number,
  :date_of_birth,
  :email
]
