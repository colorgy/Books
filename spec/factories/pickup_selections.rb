FactoryGirl.define do
  factory :pickup_selections_date, class: PickupSelections::Date do
    organization_code { %w(NTUST NTU NTNU NTHU TTU).sample }
    batch { BatchCodeService.current_batch }
    selection "Date Selection"
  end

  factory :pickup_selections_time, class: PickupSelections::Time do
    organization_code nil
    batch { BatchCodeService.current_batch }
    selection "Time Selection"
  end

  factory :pickup_selections_point, class: PickupSelections::Point do
    organization_code { %w(NTUST NTU NTNU NTHU TTU).sample }
    batch { BatchCodeService.current_batch }
    selection "Point Selection"
  end
end
