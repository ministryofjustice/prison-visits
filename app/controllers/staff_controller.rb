class StaffController < ApplicationController
  permit_only_from_prisons
end
