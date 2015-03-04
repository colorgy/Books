class RemoveDefaultsForNullFalse < ActiveRecord::Migration
  def up
    change_column_default :groups, :batch, nil
    change_column_default :groups, :organization_code, nil
  end

  def down
    change_column_default :groups, :batch, '_null_'
    change_column_default :groups, :organization_code, '_null_'
  end
end
