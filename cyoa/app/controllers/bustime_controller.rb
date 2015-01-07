class BustimeController < ApplicationController
  before_filter :instantiate_bus_api

  def routes
    render json: @bus_api.routes.map(&:as_hash).to_json
  end

  def show
  end
end
