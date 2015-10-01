class ModelLocator
  def locate(gid)
    klass = Object.const_get(gid.model_name)
    params = JSON.parse(Base64.urlsafe_decode64(gid.model_id))
    RecursiveHasher.new.import(params, klass)
  end
end
