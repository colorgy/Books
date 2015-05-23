FactoryGirl.define do
  factory :group_order, class: Order do
    group
    user { create(:user, organization_code: group.organization_code) }
    quantity 1

    initialize_with do
      user.add_to_cart(:group, group.code, quantity: quantity)
      checkouts = user.checkout!(type: :test, invoice_type: :digital)
      if quantity == 1
        checkouts[:orders].first
      else
        checkouts[:orders]
      end
    end
  end
end
