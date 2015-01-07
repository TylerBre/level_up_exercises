class BusRoute < ActiveRecord::Base
  has_many :bus_stops, dependent: :destroy

  validates_numericality_of :public_id, allow_nil: true

  def as_json(options = {})
    super(methods: :bus_stops)
  end
end
