# This is amended for Select2 3.5.x
# requires: jQuery
#
# usage example: select2_select('.select2-element-to-select', 'item_name_to_select')

module Select2Helper
  def select2_select(path, value, first: false)
    expect(page).to have_selector(path, visible: true)
    first ? first(path).click : find(path).click

    expect(page).to have_selector('.select2-search input', visible: true)
    find('.select2-search input', visible: true).set(value)
    execute_script("$('.select2-search:visible input').trigger('input');")

    expect(page).to have_content(value)
    expect(page).to have_selector('.select2-results li', visible: true)
    item = first('.select2-results li', visible: true).click

    expect(page).to have_content(value)
  end
end

RSpec.configure do |config|
  config.include Select2Helper, :type => :feature
end
