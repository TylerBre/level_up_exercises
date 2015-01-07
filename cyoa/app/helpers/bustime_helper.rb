require 'cta_apis'

module BustimeHelper
  def bus_api
    CTA::BusApi.new(APP_CONFIG['cta']['bus'])
  end
end
