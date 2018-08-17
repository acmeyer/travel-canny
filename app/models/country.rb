# coding: utf-8
# Defined by the ISO 3166 standard.  The ISO 3166 standard includes a
# "Country Subdivision Code", giving a code for the names of the principal
# administrative subdivisions of the countries coded in ISO 3166.
# 
# Data is based on http://svn.debian.org/wsvn/pkg-isocodes/trunk/iso-codes/iso_3166/iso_3166.xml?op=file
# 
# Countries are uniquely identified by their alpha 2 code.  You can access
# countries like so:
# 
#   Country['US']   # => #<Country id: 840, alpha_2_code: "US", name: "United States", official_name: "United States of America", alpha_3_code: "USA">
#   Country['CA']   # => #<Country id: 124, alpha_2_code: "CA", name: "Canada", official_name: "Canada", alpha_3_code: "CAN">
# 
# == Identification
# 
# Country ids are based on another ISO standard which assigns a numeric value
# to every country.
# 
# == Regions
# 
# Each country may or may not have a list of regions associated with it.  It
# is largely based on the ISO standard for each country.
# 
# == Performance
# 
# If plugin reloading is enabled or this model is added to your app,
# consider marking the file as unloadable like so (in the environment):
# 
#   config.after_initialize do
#     ActiveSupport::Dependencies.load_once_paths << "#{Rails.root}/vendor/plugins/has_addresses/app/models/country" # or "#{Rails.root}/app/models/country"
#   end
# 
# This will prevent the enumeration from being bootstrapped after every
# request when in development mode.
class Country < ApplicationRecord
  validates_presence_of :name, :official_name, :alpha_3_code
  validates_length_of :alpha_2_code, :is => 2
  validates_length_of :alpha_3_code, :is => 3
  
  alias_attribute :abbreviation_2, :alpha_2_code
  alias_attribute :abbreviation_3, :alpha_3_code

  has_many :itineraries
  has_many :trips, through: :itineraries

  include PgSearch
  pg_search_scope :search_countries, :against => [:name]
  
  def initialize(attributes = nil)
    super(self.class.with_defaults(attributes))
  end
  
  # Adds the default attributes for the given country attributes
  def self.with_defaults(attributes = nil)
    attributes ||= {}
    attributes.symbolize_keys!
    attributes[:official_name] = attributes[:name] unless attributes.include?(:official_name)
    attributes
  end
end
