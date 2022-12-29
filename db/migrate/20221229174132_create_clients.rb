class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients, id: false do |t|
      t.string :name
      t.string :id, null: false

      t.timestamps
    end
  end
end
