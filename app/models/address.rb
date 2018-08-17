class Address < ApplicationRecord
  belongs_to :addressable, :polymorphic => true, optional: true # optional: true required for nested forms

  validates_presence_of :street_1, :city, :postal_code

  def single_line
    multi_line.join(', ')
  end

  def multi_line
    lines = []
    lines << street_1 if street_1?
    lines << street_2 if street_2?
    
    line = ''
    line << city if city?
    if state
      line << ', ' unless line.blank?
      line << state
    end
    if postal_code?
      line << '  ' unless line.blank?
      line << postal_code
    end
    lines << line unless line.blank?
    
    lines << country if country?
    lines
  end  
end
