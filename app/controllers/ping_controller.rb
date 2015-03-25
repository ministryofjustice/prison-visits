class PingController  < ApplicationController
  respond_to :json

  def index
    respond_with { :version_number => VERSION_INFO['version_number'], :build_date => VERSION_INFO['build_date'],
      :commit_id => VERSION_INFO['commit'], :build_tag => VERSION_INFO['build_tag'] }.to_json
  end
end