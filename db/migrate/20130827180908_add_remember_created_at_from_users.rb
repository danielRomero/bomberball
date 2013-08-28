class AddRememberCreatedAtFromUsers < ActiveRecord::Migration
  change_table(:users) do |t|
    t.datetime :remember_created_at
  end
end
