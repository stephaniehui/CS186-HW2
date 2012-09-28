# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120905195452) do

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "locations", :force => true do |t|
  	t.string   "name"
  	t.string   "latitude"
  	t.string   "longitude"
  end

  create_table "posts", :force => true do |t|
  	t.integer  "author_id"
  	t.string   "author_name"
  	t.text     "text"
  	t.datetime "created_at"
  	t.integer  "location_id"
  end

  create_table "following", :force => true do |t|
  	t.integer  "follower_id" #the id of the user that is following the location
  	t.integer  "location_id" #location id that is being followed
  end

end
