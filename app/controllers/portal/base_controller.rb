# frozen_string_literal: true

# Base controller for the Coder Portal
# All portal controllers inherit from this
module Portal
  class BaseController < ApplicationController
    layout "portal"
  end
end
