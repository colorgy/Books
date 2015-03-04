module IsPickupSelections
  extend ActiveSupport::Concern

  included do
    self.table_name = name.underscore.gsub('/', '_').pluralize
  end

  module ClassMethods

    def selections_for(org_code, batch = BatchCodeService.current_batch)
      where('(organization_code = ? OR organization_code IS NULL) AND (batch = ? OR batch IS NULL)', org_code, batch).map(&:selection)
    end

  end
end
