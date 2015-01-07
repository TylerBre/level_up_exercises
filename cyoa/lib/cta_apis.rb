require 'net/http'
require 'json'
require 'active_support/core_ext/hash/conversions'
require 'pry-debugger'

class Hash
  def symbolize_keys
    t = dup
    clear
    t.each_pair { |k, v| self[k.to_sym] = v }
    self
  end
end

module CTA
  module CTAHelpers
    def request(endpoint, params = {})
      params = params.merge(key: key)
      uri = URI("#{host}" + endpoint)
      uri.query = URI.encode_www_form(params)
      parse(Net::HTTP.get_response(uri))
    end

    def parse(response)
      Hash.from_xml(response.body)["bustime_response"] || {}
    end

    def cwd
      # pwd = Rails ? Rails.root : Dir.pwd
      "#{Dir.pwd}/lib"
    end
  end

  class BusApi
    include CTAHelpers
    attr_accessor :host, :key

    BusRoute = Struct.new(:id, :name, :color, :directions, :stops, :patterns) do
      def as_hash
        self.stops = stops.map(&:to_h)
        self.patterns = patterns.map(&:symbolize_keys)
        to_h
      end
    end

    BusStop = Struct.new(:id, :name, :lat, :lng, :direction)

    BusPrediction = Struct.new(:stop_id, :route_id, :vehicle_id, :requested_at, :arrival_at, :proximity, :arrival)

    def initialize(creds)
      puts File.expand_path(__FILE__)
      @host, @key = creds['host'], creds['key']
    end

    # this is a very costly api hit, try to pull routes from file first
    def routes(try_cache = true)
      return routes_from_file if try_cache && routes_saved?

      routes_collection = request('/getroutes')['route'].map do |route|
        make_route(route)
      end

      routes_to_file(routes_collection)
      routes_collection
    end

    def route(ids = [])
      [] << ids unless ids.is_a? Array
      routes.select { |route| ids.include? route.id }
    end

    def arrival_predictions(ids = [])
      puts ids
      predictions(ids).select(&:arrival)
    end

    def departure_predictions(ids = [])
      predictions(ids).reject(&:arrival)
    end

    def predictions(ids = [])
      stop_predictions = request('/getpredictions', stpid: stop_ids(ids))['prd']
      [] << stop_predictions if stop_predictions.is_a? Hash
      stop_predictions.map do |pred|
        BusPrediction.new(pred['stpid'], pred['rt'], pred['vid'],
          pred['tmstmp'], pred['prdtm'], pred['dstp'], pred['typ'] == 'A')
      end
    end

    private

    def stop_ids(ids)
      if ids.is_a? String
        ids.scan(/\d+/).join(',')
      else
        ids
      end
    end

    def routes_to_file(routes_collection)
      json_routes = routes_collection.map(&:as_hash).to_json
      File.open("#{cwd}/cta_bus_routes.json", 'wb') do |file|
        file.write(json_routes)
      end
    end

    def routes_from_file
      json = JSON.parse(File.read("#{cwd}/cta_bus_routes.json"))
      json.map do |route|
        bus_route = BusRoute.new(route["id"], route["name"], route["color"],
          route["directions"], route["stops"], route["stops"])
        bus_route.stops = route['stops'].map do |stop|
          BusStop.new(stop['id'], stop['name'], stop['lat'], stop['lng'],
            stop['direction'])
        end

        bus_route
      end
    end

    def routes_saved?
      File.exist? "#{cwd}/cta_bus_routes.json"
    end

    def route_directions(route)
      route_dir = request('/getdirections', rt: route.id)['dir']
      route_dir = [] << route_dir if route_dir.is_a? String
      route_dir
    end

    def route_stops(route)
      route.directions.inject([]) do |result, direction|
        stops = request('/getstops', rt: route.id, dir: direction)['stop']
        if stops.is_a? Array
          result += stops.map { |s| make_stop(s, direction) }
        else
          result << make_stop(stops, direction)
        end
        result
      end
    end

    def make_stop(stop, direction)
      busStop = BusStop.new(stop['stpid'], stop['stpnm'], stop['lat'], stop['lon'],
        direction)
    end

    def route_patterns(route)
      patterns = request('/getpatterns', rt: route.id)['ptr']
      return [] if patterns.nil? || patterns.is_a?(Hash)
      patterns.map do |pattern|
        pattern['pt'].map do |point|
          point['direction'] = pattern['rtdir']
          point
        end
      end.flatten
    end

    def make_route(route)
      route = BusRoute.new(route['rt'], route['rtnm'], route['rtclr'])
      route.directions = route_directions(route)
      route.stops = route_stops(route)
      route.patterns = route_patterns(route)
      route
    end
  end
end
