class Uptime < ActiveRecord::Base
  include Model

  validates :offset, :presence => true

  belongs_to :user
end
