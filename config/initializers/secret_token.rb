PrisonVisits2::Application.config.secret_key_base = Rails.env.production? ? ENV['SESSION_SECRET_KEY'] : \
'3662c7f598407fabb32f3eca3e9be573deffb194dedd918a19fa383429f83a5484f17e27e11137a369877ecb83dfe061789f618ddc20d50ee428ce6c506acd21'
