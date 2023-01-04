class DropReportsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :reports do |t|
      t.string :client
      t.string :type
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
