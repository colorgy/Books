FactoryGirl.define do
  factory :group_order, class: Order do
    group
    user { create(:user, organization_code: group.organization_code) }
    quantity 1

    initialize_with do
      user.add_to_cart(:group, group.code, quantity: quantity)
      bill_attrs = { type: :test, invoice_type: :digital }
      checkouts = user.checkout!(bill_attrs, package_attrs: nil)
      if quantity == 1
        checkouts[:orders].first
      else
        checkouts[:orders]
      end
    end
  end
end
