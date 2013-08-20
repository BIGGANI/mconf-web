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

ActiveRecord::Schema.define(:version => 20130717195517) do

  create_table "admissions", :force => true do |t|
    t.string   "type"
    t.integer  "candidate_id"
    t.string   "candidate_type"
    t.string   "email"
    t.integer  "group_id"
    t.string   "group_type"
    t.integer  "role_id"
    t.string   "code"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "processed_at"
    t.integer  "introducer_id"
    t.string   "introducer_type"
    t.text     "comment"
    t.boolean  "accepted"
    t.integer  "event_id"
  end

  create_table "agenda_dividers", :force => true do |t|
    t.integer  "agenda_id"
    t.string   "title"
    t.datetime "start_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "end_time"
  end

  create_table "agenda_entries", :force => true do |t|
    t.integer  "agenda_id"
    t.string   "title"
    t.text     "description"
    t.string   "speakers"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "embedded_video"
    t.text     "video_thumbnail"
    t.text     "uid"
    t.text     "divider"
    t.integer  "video_type"
  end

  create_table "agenda_record_entries", :force => true do |t|
    t.integer  "agenda_id"
    t.string   "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "record"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "agendas", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "slot",       :default => 15
  end

  create_table "attachments", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "event_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "agenda_entry_id"
    t.integer  "version_child_id"
    t.integer  "version_family_id"
  end

  add_index "attachments", ["version_child_id"], :name => "index_attachments_on_version_child_id"
  add_index "attachments", ["version_family_id"], :name => "index_attachments_on_version_family_id"

  create_table "bigbluebutton_metadata", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bigbluebutton_playback_formats", :force => true do |t|
    t.integer  "recording_id"
    t.string   "format_type"
    t.string   "url"
    t.integer  "length"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "bigbluebutton_recordings", :force => true do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.string   "recordid"
    t.string   "meetingid"
    t.string   "name"
    t.boolean  "published",  :default => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "available",  :default => true
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "bigbluebutton_recordings", ["recordid"], :name => "index_bigbluebutton_recordings_on_recordid", :unique => true
  add_index "bigbluebutton_recordings", ["room_id"], :name => "index_bigbluebutton_recordings_on_room_id"

  create_table "bigbluebutton_rooms", :force => true do |t|
    t.integer  "server_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "meetingid"
    t.string   "name"
    t.string   "attendee_password"
    t.string   "moderator_password"
    t.string   "welcome_msg"
    t.string   "logout_url"
    t.string   "voice_bridge"
    t.string   "dial_number"
    t.integer  "max_participants"
    t.boolean  "private",            :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "external",           :default => false
    t.string   "param"
    t.boolean  "record",             :default => false
    t.integer  "duration",           :default => 0
  end

  add_index "bigbluebutton_rooms", ["meetingid"], :name => "index_bigbluebutton_rooms_on_meetingid", :unique => true
  add_index "bigbluebutton_rooms", ["server_id"], :name => "index_bigbluebutton_rooms_on_server_id"
  add_index "bigbluebutton_rooms", ["voice_bridge"], :name => "index_bigbluebutton_rooms_on_voice_bridge", :unique => true

  create_table "bigbluebutton_servers", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "salt"
    t.string   "version"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "param"
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description",             :limit => 255
    t.string   "place"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "machine_id"
    t.string   "colour",                                 :default => ""
    t.string   "repeat"
    t.integer  "at_job"
    t.integer  "parent_id"
    t.boolean  "character"
    t.boolean  "public_read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.boolean  "spam",                                   :default => false
    t.text     "notes"
    t.text     "location"
    t.text     "other_streaming_url"
    t.string   "permalink"
    t.integer  "vc_mode",                                :default => 0
    t.text     "other_participation_url"
    t.boolean  "web_interface",                          :default => false
    t.boolean  "sip_interface",                          :default => false
    t.datetime "generate_pdf_at"
    t.datetime "generate_scorm_at"
    t.integer  "web_bw"
    t.integer  "recording_bw"
    t.datetime "generate_pdf_small_at"
    t.boolean  "streaming_by_default",                   :default => true
    t.boolean  "manual_configuration",                   :default => false
    t.integer  "recording_type",                         :default => 0
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.string   "mailing_list"
  end

  create_table "join_requests", :force => true do |t|
    t.string   "request_type"
    t.integer  "candidate_id"
    t.integer  "introducer_id"
    t.integer  "group_id"
    t.string   "group_type"
    t.string   "comment"
    t.string   "email"
    t.boolean  "accepted"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "processed_at"
  end

  create_table "logos", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.string   "logoable_type"
    t.integer  "logoable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machines", :force => true do |t|
    t.string  "name",          :limit => 40, :default => "",    :null => false
    t.string  "nickname",      :limit => 40, :default => "",    :null => false
    t.boolean "public_access",               :default => false
  end

  create_table "machines_users", :id => false, :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "machine_id", :null => false
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manager",    :default => false
  end

  create_table "news", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "space_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "participants", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "attend"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "subject_id",   :null => false
    t.string   "subject_type", :null => false
    t.integer  "role_id",      :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "post_attachments", :force => true do |t|
    t.integer "post_id"
    t.integer "attachment_id"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reader_id"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "parent_id"
    t.integer  "event_id"
    t.boolean  "spam",        :default => false
  end

  create_table "private_messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "parent_id"
    t.boolean  "checked",                            :default => false
    t.string   "title"
    t.text     "body",                :limit => 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted_by_sender",                  :default => false
    t.boolean  "deleted_by_receiver",                :default => false
  end

  create_table "profiles", :force => true do |t|
    t.string  "organization"
    t.string  "phone"
    t.string  "mobile"
    t.string  "fax"
    t.string  "address"
    t.string  "city"
    t.string  "zipcode"
    t.string  "province"
    t.string  "country"
    t.integer "user_id",      :limit => 255
    t.string  "prefix_key",                  :default => ""
    t.text    "description"
    t.string  "url"
    t.string  "skype"
    t.string  "im"
    t.integer "visibility",                  :default => 3
    t.string  "full_name"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "stage_type"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "domain"
    t.string   "smtp_login"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ssl",                            :default => false
    t.boolean  "exception_notifications",        :default => false
    t.string   "exception_notifications_email"
    t.text     "signature"
    t.string   "presence_domain"
    t.string   "feedback_url"
    t.boolean  "shib_enabled",                   :default => false
    t.string   "shib_name_field"
    t.string   "shib_email_field"
    t.string   "exception_notifications_prefix"
    t.string   "smtp_password"
    t.string   "analytics_code"
    t.boolean  "chat_enabled",                   :default => false
    t.string   "xmpp_server"
    t.boolean  "smtp_auto_tls"
    t.string   "smtp_server"
    t.integer  "smtp_port"
    t.boolean  "smtp_use_tls"
    t.string   "smtp_domain"
    t.string   "smtp_auth_type"
    t.string   "smtp_sender"
    t.string   "timezone",                       :default => "UTC"
    t.string   "external_help"
  end

  create_table "spaces", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "deleted"
    t.boolean  "public",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "permalink"
    t.boolean  "disabled",    :default => false
    t.boolean  "repository",  :default => false
  end

  create_table "statistics", :force => true do |t|
    t.string   "url"
    t.integer  "unique_pageviews"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",                        :null => false
    t.integer "taggable_id",                   :null => false
    t.string  "taggable_type", :default => "", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string  "name",           :default => "", :null => false
    t.integer "container_id"
    t.string  "container_type"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name", "container_id", "container_type"], :name => "index_tags_on_name_and_container_id_and_container_type"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 40, :default => "",    :null => false
    t.string   "password_salt",          :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "superuser",                            :default => false
    t.boolean  "disabled",                             :default => false
    t.datetime "confirmed_at"
    t.string   "timezone",                             :default => "UTC"
    t.boolean  "expanded_post",                        :default => false
    t.integer  "notification",                         :default => 1
    t.string   "locale"
    t.integer  "receive_digest",                       :default => 0
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
