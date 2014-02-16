require 'active_record'
require 'geoip'

class City < ActiveRecord::Base

  def self.geo
    @@geo ||= GeoIP.new("#{$root}/data/GeoLiteCity.dat")
  end
  
  def self.by_host(host)
    c = geo.city(host)
    return none unless c
    where(city_name:c.city_name, 
        region_name:c.region_name.encode('US-ASCII'), 
       country_name:c.country_name, 
       continent_code:c.continent_code)
  end
end