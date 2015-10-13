class StaffController < ApplicationController
  permit_only_trusted_users
end
