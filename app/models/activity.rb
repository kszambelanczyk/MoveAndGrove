class Activity < ApplicationRecord

  belongs_to :activity_type

  belongs_to :user

  validates :start, presence: { message: "Please fill up the activity start time"}
  validates :duration, 
    presence: { message: "Please fill up the activity duration" }, 
    numericality: { 
      only_integer: true, 
      greater_than: 0,
      message: "Activity duration is not a number or is not greater than zero" 
    }
  
end
