module BillService
  class << self
    def allowed_bill_types
      return @allowed_bill_types if @allowed_bill_types.present?
      @allowed_bill_types = (ENV['ALLOWED_BILL_TYPES'].split(',') & %w(payment_code credit_card virtual_account test)).map(&:to_sym)
    end

    def bill_type_selections
      @bill_type_selections ||= allowed_bill_types.map { |bt| [I18n.t(bt, scope: :bill_types), bt] }
    end

    def bill_type_label(bt)
      I18n.t(bt, scope: :bill_types)
    end

    def invoice_type_label(bit)
      I18n.t(bit, scope: :invoice_types)
    end
  end
end
