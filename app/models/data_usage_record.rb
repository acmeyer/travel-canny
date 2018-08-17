class DataUsageRecord < ApplicationRecord
  belongs_to :user, touch: true

  def total_usage_mb
    if self.total_usage
      (self.total_usage / 1000000.0).round(3)
    else
      0
    end
  end
end
