# frozen_string_literal: true

module Coders
  class DashboardController < ApplicationController
    skip_before_action :authenticate_user!, only: [] # Ensure auth

    def index
      # This is the landing page for logged-in coders (non-admins)
    end
  end
end
