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

ActiveRecord::Schema.define(version: 2020_12_11_124819) do

  create_table "books", charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.integer "quantity", limit: 1
    t.integer "loans_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "loans", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "book_id"
    t.datetime "borrow_at"
    t.datetime "return_at"
    t.integer "amount", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_loans_on_book_id"
    t.index ["borrow_at"], name: "index_loans_on_borrow_at"
    t.index ["return_at"], name: "index_loans_on_return_at"
    t.index ["user_id"], name: "index_loans_on_user_id"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.integer "amount", limit: 2
    t.integer "escrow", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
