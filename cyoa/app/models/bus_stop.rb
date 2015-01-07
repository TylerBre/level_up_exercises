class BusStop < ActiveRecord::Base
  belongs_to :bus_route

  validates_numericality_of :lat, :lng, :public_id, allow_nil: true
  # validates_uniqueness_of :sequence_order, scope: :direction
end
