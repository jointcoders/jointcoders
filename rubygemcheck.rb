#!/usr/bin/env ruby

#
# This is a little thing that will run and you
# can just add whatever gems are needed to the
# required gems at the top. If any fail to load
# it will print a failure, add them to an array
# and print the array on exit listing all failures
 
required_gems = ['qtbindings']
missing_gems = Array.new
required_gems.each do |testgem|
  begin
    gem testgem
    # with requirements
    #gem "qtbindings", ">=4.0"
    puts "Gem #{testgem} is installed.....\033[32mOK\033[0m"
  rescue Gem::LoadError
    # not instailled
    puts "Gem #{testgem} is installed.....\033[31mFAIL\033[0m"
    missing_gems.push testgem
  end
end

if missing_gems.any? then
  puts ''
  puts 'The following gems failed to load:'
  missing_gems.each do |gem|
    puts gem
  end
  exit
end
