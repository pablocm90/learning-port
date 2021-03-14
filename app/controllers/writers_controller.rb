# frozen_string_literal: true

class WritersController < ApplicationController
  before_action :authenticate_writer!

  def dashboard; end
end
