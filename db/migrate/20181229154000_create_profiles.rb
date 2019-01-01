class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.integer :user_id, null: false
      t.string :name
      t.string :brokerage
      t.string :phone
      t.string :emailcontact
      t.string :photo_file_name
      t.string :photo_content_type
      t.string :photo_file_size
      t.timestamps
    end

    add_index :profiles, :user_id, unique: true
  end
end
