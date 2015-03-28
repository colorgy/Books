class AddUuidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uuid, :string
    add_index :users, :uuid, unique: true

    User.find_each do |user|
      next if user.uuid.present?
      user.generate_uuid(ENV['CORE_URL'])
      user.save!(validate: false)
    end

    change_column :users, :uuid, :string, null: false
  end
end
