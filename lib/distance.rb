require "net/http"
require "json"
RADIUS = 6371

##
def to_radians(degrees)
  radians = degrees * Math::PI / 180 
end

##
def location_dist_difference(lat1,lon1,lat2,lon2)
	dLat = to_radians(lat2-lat1)
	dLon = to_radians(lon2-lon1)
	lat1 = to_radians(lat1)
	lat2 = to_radians(lat2)

	#‘haversine’ formula
	a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	d = RADIUS * c
	return d
end


