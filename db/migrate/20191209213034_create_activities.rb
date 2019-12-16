class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|

      t.integer :duration
      t.datetime :start

      t.belongs_to :activity_type, foreign_key: true

      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
