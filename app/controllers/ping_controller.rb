class PingController < ApplicationController
  def index
    render json: {
      version_number:  VERSION_INFO['version_number'],
      build_date:      VERSION_INFO['build_date'],
      commit_id:       VERSION_INFO['commit'],
      build_tag:       VERSION_INFO['build_tag']
    }
  end
end
