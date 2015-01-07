require 'cta_apis'

namespace :bus_api do
  desc 'Updates all cta seed data'
  task seed: :environment do
    BusRoute.destroy_all
    bus_api = CTA::BusApi.new(APP_CONFIG['cta']['bus'])

    bus_api.routes(false).each do |route|
      bus_route = BusRoute.new
      bus_route.public_id = route.id
      bus_route.name = route.name
      bus_route.color = route.color
      bus_route.directions = route.directions.join(',')

      route.patterns.each do |pat|
        bus_stop = BusStop.new

        bus_stop.direction = pat[:direction]
        bus_stop.lat = pat[:lat].to_f
        bus_stop.lng = pat[:lon].to_f
        bus_stop.waypoint = pat[:typ] == 'W'
        bus_stop.sequence_order = pat[:seq]

        unless pat[:typ] == 'W'
          bus_stop.name = pat[:stpnm]
          bus_stop.feet_from_start = pat[:pdist]

          pattern_stop = route[:stops].select do |s|
            pat[:stpid].to_i == s[:id].to_i
          end.first

          if pattern_stop
            puts "Couldn't find a bus stop for this pattern: Route #{bus_route.public_id} Stop #{pat[:stpid]}"
          end

          bus_stop.public_id = pattern_stop[:id]
        end

        # de-dup
        if bus_route.bus_stops.size == 0
          bus_route.bus_stops << bus_stop
        else
          no_match = bus_route.bus_stops.none? do |stop|
            stop.direction == bus_stop.direction && stop.sequence_order == bus_stop.sequence_order
          end

          bus_route.bus_stops << bus_stop if no_match
        end
      end

      bus_route.save
    end
  end
end
