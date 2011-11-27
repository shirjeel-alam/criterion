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

ActiveRecord::Schema.define(:version => 20111120194344) do

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.integer  "teacher_id"
    t.integer  "session_id"
    t.integer  "monthly_fee"
    t.integer  "status"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "student_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "payable_id"
    t.string   "payable_type"
    t.date     "period"
    t.integer  "amount"
    t.boolean  "status"
    t.boolean  "payment_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "paid_on"
  end

  create_table "phone_numbers", :force => true do |t|
    t.string   "number"
    t.integer  "category"
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.integer  "period"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "registration_fee"
    t.boolean  "fee_status",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.float    "share"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
