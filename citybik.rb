require 'rubygems'
require 'json'
require 'yaml'
require 'mongo'
require 'rest-client'
require 'colorize'
load 'interscity_entity.rb'

project_path = "./"
project_path = ARGV[0] unless ARGV[0].nil?

config = YAML.load_file("#{project_path}settings.yml")

db = Mongo::Client.new([ config["DATABASE_HOST"] ], :database => config["DATABASE_NAME"])
collection = db[:bike_stations]

class BikeStation < InterSCityEntity
  attr_accessor :region, :address, :free_bikes, :slots

  def initialize(params={})
    super
    self.description = "#{self.info} bike station, from #{self.address}"
  end

  def self.to_hash(raw)
    {
      empty_slots: raw["empty_slots"],
      address: raw["extra"]["address"],
      free_bikes: raw["free_bikes"],
      external_uid: raw["id"],
      lat: raw["latitude"],
      lon: raw["longitude"],
      slots: raw["extra"]["slots"],
      info: raw["name"],
      status: raw["extra"]["status"]
    }
  end

  def normalized_update_data
    {
      free_bikes: [{value: self.free_bikes, timestamp: self.timestamp}],
      slots: [{value: self.slots, timestamp: self.timestamp}]
    }
  end

  def normalized_registration_data
    {
      lat: self.lat,
      lon: self.lon,
      description: self.description,
      capabilities: self.capabilities,
      status: self.status
    }
  end

  def capabilities
    ["slots", "free_bikes", "address", "external_uid"]
  end
end

# add new network_ids from `https://api.citybik.es/v2/networks`
networks_ids = ["bikesantos"]
resources = {}
base_url = "https://api.citybik.es/v2/"

networks_ids.each do |nw|
  url = base_url + "/networks/#{nw}"
  response = RestClient.get(url)
  network = JSON.parse(response)["network"]

  collection.insert_one(network)

  if ENV["USE_INTERSCITY"] && ENV["INTERSCITY_ADAPTOR_HOST"]
    network["stations"].each do |sta|
      normalized_attrs = BikeStation.to_hash(sta)
      bs = BikeStation.new(normalized_attrs)
      bs.register
      if bs.registered
        resources.update("#{bs.uuid}" => bs)
      end
    end
  else
    puts ">>> InterSCity configuration not found <<<"
  end
end

if ENV["USE_INTERSCITY"] && ENV["INTERSCITY_ADAPTOR_HOST"]
  resources.each do |key, entity|
    entity.send_data
  end
end
