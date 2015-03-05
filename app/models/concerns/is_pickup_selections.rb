module IsPickupSelections
  extend ActiveSupport::Concern

  included do
    self.table_name = name.underscore.gsub('/', '_').pluralize
  end

  module ClassMethods

    def selections_for(org_code, batch = BatchCodeService.current_batch)
      if org_code.is_a?(Group)
        group = org_code
        org_code = group.organization_code
        batch = group.batch
      end
      where('(organization_code = ? OR organization_code IS NULL) AND (batch = ? OR batch IS NULL)', org_code, batch).map(&:selection)
    end
  end
end
