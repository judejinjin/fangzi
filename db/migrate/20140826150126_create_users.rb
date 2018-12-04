class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false, default: ""
      t.string :session_token

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :session_token
  end
end
