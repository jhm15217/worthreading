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

ActiveRecord::Schema.define(:version => 20120719211513) do

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "relationships", :force => true do |t|
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "subscriber_id"
    t.integer  "subscribed_id"
  end

  add_index "relationships", ["subscribed_id", "subscriber_id"], :name => "index_relationships_on_subscribed_id_and_subscriber_id", :unique => true
  add_index "relationships", ["subscribed_id"], :name => "index_relationships_on_subscribed_id"
  add_index "relationships", ["subscriber_id"], :name => "index_relationships_on_subscriber_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",              :default => false
    t.integer  "likes"
    t.boolean  "confirmed",          :default => false
    t.integer  "confirmation_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "wr_logs", :force => true do |t|
    t.string   "action"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "email_id"
    t.integer  "email_part"
    t.boolean  "responded"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
