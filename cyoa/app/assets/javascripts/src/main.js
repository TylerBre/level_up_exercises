(function (L) {

  function BusMap () {
    $('body').attr('id', 'js-bus-map');
    this.map = L.mapbox.map('js-bus-map', 'tylerbre.kf2oil5f', {
      accessToken: 'pk.eyJ1IjoidHlsZXJicmUiLCJhIjoicFl5ZjM4WSJ9.qesmbAiQmAxKIxIXsX8gKg'
    });

    this.defaults = {
      zoom: 18,
      coords: [41.8784609, -87.63415],
      routes: []
    };
  }

  BusMap.prototype.userPosition = function (cb) {
    var self = this;
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(function (pos) {
        cb([pos.coords.latitude, pos.coords.longitude]);
      });
    } else {
      cb(this.defaults.coords); // 200 w jackson
    }
  };

  BusMap.prototype.setRouteMarkers = function() {
    var self = this;
    $.get('/api/bustime/routes').done(function (data) {
      self.defaults.routes = data;
      self.routePatterns().forEach(function (pattern) {

        // L.marker([busStop.lat, busStop.lng], {
        //   icon: L.mapbox.marker.icon({
        //     'marker-size': 'small',
        //     'marker-color': '#eaa'
        //   })
        // }).addTo(self);
        var points = [];

        for (var key in pattern) {
          points.push(pattern[key].map(formatPoint));
        }

        function formatPoint (point) {
          return L.latLng(parseFloat(point.lat), parseFloat(point.lng));
        }
        L.multiPolyline(points, {
          color: '#eaa'
        }).addTo(self.map);
      });
    });
  };

  BusMap.prototype.busStops = function () {
    return this.defaults.routes.reduce(function (stops, route) {
      // return stops.concat(route.stops);
      var routeCoords = route.stops.reduce(function (routeStops, stop) {
        routeStops.push([parseFloat(stop.lat), parseFloat(stop.lng)]);
        return routeStops;
      }, []);

      stops.push(routeCoords);
      return stops;
    }, []);
  };

  BusMap.prototype.routePatterns = function () {
    return this.defaults.routes.map(function (route) {
      return _.chain(route.bus_stops)
        .sortBy('sequence_order')
        .groupBy('direction')
        .value();
    });
  };

  BusMap.prototype.center = function (latLng) {
    latLng = latLng || this.defaults.coords;

    this.setView(latLng, this.defaults.zoom);
  };

  /*==========  interface  ==========*/
  var busMap = new BusMap();

  busMap.userPosition(function (position) {
    busMap.map.setView(position, busMap.defaults.zoom, {
      reset: true,
      zoom: {
        animate: true
      }
    });
    busMap.setRouteMarkers();
  });
})(L);
