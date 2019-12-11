class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|

      t.integer :duration
      t.datetime :start

      t.references :activity_types, foreign_key: true
      t.references :users, foreign_key: true

      t.timestamps
    end
  end
end
