require 'rabl'
Rabl.configure do |config|
  config.include_json_root = false
  config.include_xml_root  = false
  config.enable_json_callbacks = true
  config.include_child_root = false
end
