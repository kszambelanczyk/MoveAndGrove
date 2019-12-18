class ActivityType < ApplicationRecord
    mount_uploader :image, ActivityTypeUploader

    has_many :activities
end
