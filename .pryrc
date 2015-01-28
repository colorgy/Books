begin
  require "awesome_print"
  require "hirb"
  require "hirb-unicode"
  extend Hirb::Console
rescue LoadError => e
end
