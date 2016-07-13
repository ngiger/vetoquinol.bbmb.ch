#!/usr/bin/env ruby
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com

here = File.expand_path(File.dirname(__FILE__))
$: << here

require 'find'

Find.find(here) do |file|
  next if /selenium/.match(file)
  if /test_.*\.rb$/o.match(file)
    require file
  end
end
puts "Skipped all selenium tests!"
