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

ActiveRecord::Schema.define(version: 20131119101000) do

  create_table "cities", force: true do |t|
    t.string  "country_code2"
    t.string  "country_code3"
    t.string  "country_name"
    t.string  "continent_code"
    t.string  "region_name"
    t.string  "city_name"
    t.string  "postal_code"
    t.float   "latitude"
    t.float   "longitude"
    t.integer "dma_code"
    t.integer "area_code"
    t.string  "timezone"
  end

  create_table "entries", force: true do |t|
    t.string   "host"
    t.datetime "timestamp"
    t.string   "major_os_version"
    t.string   "os_version"
    t.integer  "cputype"
    t.boolean  "cpu64bit"
    t.integer  "cpusubtype"
    t.string   "model"
    t.integer  "ncpu"
    t.string   "lang"
    t.string   "app_version"
    t.integer  "cpu_freq_m_hz"
    t.integer  "ram_mb"
    t.integer  "city_id"
  end

end
