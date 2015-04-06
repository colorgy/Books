# This is amended for Select2 3.5.x
# requires: jQuery
#
# usage example: select2_select('.select2-element-to-select', 'item_name_to_select')

module Select2Helper
  def select2_select(path, value, first: false)
    first ? first(path).click : find(path).click

    expect(page).to have_selector('.select2-search input', visible: true)
    find('.select2-search input', visible: true).set(value)
    execute_script("$('.select2-search:visible input').trigger('input');")

    expect(page).to have_content(value)
    item = nil
    10.times do
      expect(page).to have_selector('.select2-results li', visible: true)
      item = first('.select2-results li', visible: true)
      p item
      break if item
    end
    item.click

    expect(page).to have_content(value)
  end
end

RSpec.configure do |config|
  config.include Select2Helper, :type => :feature
end
