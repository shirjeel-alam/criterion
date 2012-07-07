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

ActiveRecord::Schema.define(:version => 20120707071532) do

  create_table "account_entries", :force => true do |t|
    t.integer  "criterion_account_id"
    t.integer  "payment_id"
    t.integer  "amount"
    t.boolean  "entry_type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "role"
    t.integer  "user_id"
    t.string   "user_type"
    t.boolean  "status",                 :default => true
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.integer  "teacher_id"
    t.integer  "session_id"
    t.integer  "monthly_fee"
    t.integer  "status"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.date     "course_date"
    t.integer  "level"
  end

  create_table "criterion_accounts", :force => true do |t|
    t.integer  "admin_user_id"
    t.integer  "initial_balance", :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "account_type"
  end

  create_table "criterion_mails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.string   "cc"
    t.string   "bcc"
    t.string   "subject"
    t.text     "body"
    t.integer  "mailable_id"
    t.string   "mailable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "criterion_report_dates", :force => true do |t|
    t.date     "report_date"
    t.integer  "criterion_report_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "criterion_reports", :force => true do |t|
    t.integer  "gross_revenue"
    t.integer  "discounts"
    t.integer  "net_revenue"
    t.integer  "expenditure"
    t.integer  "balance"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.boolean  "closed"
  end

  create_table "criterion_sms", :force => true do |t|
    t.string   "to"
    t.text     "message"
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.boolean  "status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "student_id"
    t.integer  "course_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "status"
    t.date     "enrollment_date"
    t.date     "start_date"
  end

  create_table "partners", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.float    "share"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "payments", :force => true do |t|
    t.integer  "payable_id"
    t.string   "payable_type"
    t.date     "period"
    t.integer  "amount"
    t.integer  "status"
    t.boolean  "payment_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "discount"
    t.date     "payment_date"
    t.integer  "category_id"
    t.integer  "payment_method"
    t.text     "additional_info"
  end

  create_table "phone_numbers", :force => true do |t|
    t.string   "number"
    t.integer  "category"
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "session_students", :force => true do |t|
    t.integer  "student_id"
    t.integer  "session_id"
    t.integer  "payment_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.integer  "period"
    t.integer  "year"
    t.integer  "registration_fee"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "status"
  end

  create_table "staffs", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "students", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "address"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.float    "share"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
