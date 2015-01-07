class BustimeRoutesController < ApplicationController
  include BustimeHelper
  respond_to :json

  def index
    # @routes = bus_api.routes
    # puts @routes.first.patterns
    @routes = BusRoute.includes(:bus_stops)
    # @routes = BusRoute.all.joins(:bus_stops)
    # respond_with(@routes)
    render json: @routes
  end

  def show
    @routes = bus_api.route(params[:id])
    respond_with(@routes)
  end

  def search
    @routes = bus_api.route(params[:ids])
    respond_with(@routes)
  end
end
