class CreatePgheroQueryStats < ActiveRecord::Migration[8.0]
  enable_extension "pg_stat_statements" unless extension_enabled?("pg_stat_statements")

  def change
    create_table :pghero_query_stats do |t|
      t.text :database
      t.text :user
      t.text :query
      t.integer :query_hash, limit: 8
      t.float :total_time
      t.integer :calls, limit: 8
      t.timestamp :captured_at
    end

    add_index :pghero_query_stats, [:database, :captured_at]
  end
end
