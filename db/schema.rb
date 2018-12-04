# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_12_03_012356) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "album_photos", force: :cascade do |t|
    t.integer "property_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.index ["property_id"], name: "index_album_photos_on_property_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "author_id", null: false
    t.integer "property_id", null: false
    t.string "title", null: false
    t.string "body", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["property_id"], name: "index_comments_on_property_id"
  end

  create_table "properties", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "address", null: false
    t.string "unit"
    t.string "zip", null: false
    t.string "neighborhood"
    t.integer "price", null: false
    t.integer "beds"
    t.decimal "baths"
    t.integer "sq_ft"
    t.string "apt_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "borough"
    t.string "property_photo_file_name"
    t.string "property_photo_content_type"
    t.integer "property_photo_file_size"
    t.datetime "property_photo_updated_at"
    t.float "latitude"
    t.float "longitude"
    t.text "description"
    t.index ["address", "unit"], name: "index_properties_on_address_and_unit", unique: true
    t.index ["apt_type"], name: "index_properties_on_apt_type"
    t.index ["baths"], name: "index_properties_on_baths"
    t.index ["beds"], name: "index_properties_on_beds"
    t.index ["borough"], name: "index_properties_on_borough"
    t.index ["neighborhood"], name: "index_properties_on_neighborhood"
    t.index ["owner_id"], name: "index_properties_on_owner_id"
    t.index ["price"], name: "index_properties_on_price"
    t.index ["sq_ft"], name: "index_properties_on_sq_ft"
    t.index ["zip"], name: "index_properties_on_zip"
  end

  create_table "property_saves", force: :cascade do |t|
    t.integer "property_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["property_id", "user_id"], name: "index_property_saves_on_property_id_and_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "session_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.text "image"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["session_token"], name: "index_users_on_session_token"
  end

end
