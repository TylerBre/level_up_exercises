class BustimeArrivalsController < ApplicationController
  include BustimeHelper
  respond_to :json

  def search
    @arrivals = bus_api.arrival_predictions(params[:ids])
    respond_with(@arrivals)
  end
end
