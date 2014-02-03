# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :first_name, :last_name, :number, :'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)']
