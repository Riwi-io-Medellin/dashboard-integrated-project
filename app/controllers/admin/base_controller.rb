# frozen_string_literal: true

# Base controller for admin namespace
module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    layout "admin"
  end
end
