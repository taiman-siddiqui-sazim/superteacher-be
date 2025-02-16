# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_16_072029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.string "title"
    t.text "instruction"
    t.string "file_url"
    t.string "due_date"
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "assignment_type", default: "assignment", null: false
    t.index ["classroom_id"], name: "index_assignments_on_classroom_id"
    t.check_constraint "assignment_type::text = ANY (ARRAY['exam'::character varying, 'assignment'::character varying]::text[])", name: "valid_assignment_type"
  end

  create_table "classroom_students", force: :cascade do |t|
    t.bigint "classroom_id", null: false
    t.bigint "student_id", null: false
    t.date "enroll_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_classroom_students_on_classroom_id"
    t.index ["student_id"], name: "index_classroom_students_on_student_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.string "title"
    t.string "subject"
    t.string "class_time"
    t.string "days_of_week", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "teacher_id", null: false
    t.index ["teacher_id"], name: "index_classrooms_on_teacher_id"
  end

  create_table "meet_links", force: :cascade do |t|
    t.string "meet_link"
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_meet_links_on_classroom_id"
    t.index ["meet_link"], name: "index_meet_links_on_meet_link", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.string "sender_type", null: false
    t.integer "sender_id", null: false
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_messages_on_classroom_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "students", force: :cascade do |t|
    t.string "phone", limit: 15, null: false
    t.string "address", limit: 100
    t.string "education_level", null: false
    t.string "medium"
    t.integer "year"
    t.string "degree_type"
    t.string "degree_name", limit: 50
    t.string "semester_year", limit: 25
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "subject", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "assignment_id", null: false
    t.bigint "user_id", null: false
    t.datetime "submitted_at"
    t.string "file_url"
    t.boolean "is_late"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "major_subject", limit: 50, null: false
    t.string "subjects", default: [], null: false, array: true
    t.string "highest_education", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_teachers_on_user_id"
  end

  create_table "unique_codes", force: :cascade do |t|
    t.string "email", null: false
    t.string "unique_code", limit: 6, null: false
    t.integer "attempts_left", default: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_unique_codes_on_email", unique: true
    t.index ["unique_code"], name: "index_unique_codes_on_unique_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 50, null: false
    t.string "last_name", limit: 50, null: false
    t.string "gender", null: false
    t.string "email", null: false
    t.string "user_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "otp"
    t.datetime "otp_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "user_type::text = ANY (ARRAY['student'::character varying, 'teacher'::character varying]::text[])", name: "user_type_check"
  end

  add_foreign_key "assignments", "classrooms"
  add_foreign_key "classroom_students", "classrooms"
  add_foreign_key "classroom_students", "students"
  add_foreign_key "classrooms", "users", column: "teacher_id"
  add_foreign_key "meet_links", "classrooms"
  add_foreign_key "messages", "classrooms"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "students", "users"
  add_foreign_key "submissions", "assignments"
  add_foreign_key "submissions", "users"
  add_foreign_key "teachers", "users"
end
