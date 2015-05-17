class LetGroupsOrganizationCodeCanBeNull < ActiveRecord::Migration
  def change
    change_column :groups, :organization_code, :string, null: true
  end
end
