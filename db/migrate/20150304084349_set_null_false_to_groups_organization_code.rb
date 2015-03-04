class SetNullFalseToGroupsOrganizationCode < ActiveRecord::Migration
  def up
    Group.where(organization_code: nil).each { |o| o.set_organization_code! }
    change_column :groups, :organization_code, :string, null: false, default: '_null_'
  end

  def down
    change_column :groups, :organization_code, :string, null: true
  end
end
