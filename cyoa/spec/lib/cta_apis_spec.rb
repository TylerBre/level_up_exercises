require 'spec_helper'
require 'rails_helper'
require 'cta_apis'

describe CTA::BusApi do
  context 'with a valid key and host' do
    subject(:bus_api) do
      CTA::BusApi.new(APP_CONFIG['cta']['bus']['host'], APP_CONFIG['cta']['bus']['key'])
    end

    it "should know that it lives in ./lib" do
      expect(bus_api.cwd).to eq("#{Rails.root}/lib")
    end
    it "should fetch a collection of route data"
    it "should dynamically cache the collection of routes"
    it "should know if the cache exists or not"
    it "should be able to get bus times based on a collection of routes"
  end
end
