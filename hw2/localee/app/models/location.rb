class Location < ActiveRecord::Base
	def to_hash
    {
      :id => self.id,
      :name => self.name,
      :latitude => self.latitude
      :longitude => self.longitude
    }
  end

end