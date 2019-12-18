class AddCaloriesFactorToActivityTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :activity_types, :calories_factor, :integer
  end
end
