#!/usr/bin/env ruby -w
#
#  Created by Mark Holton (holtonma@gmail.com) on 2009-01-10.
 
require 'daemonize'
require 'date'
# Mark Holton, Jan 2009...
require 'carl_spackler'
require 'sample_store_to_db'
 
include CARL_SPACKLER
include Daemonize
 
my_db = DB.new("76.12.19.132", "golfap", "Aviaryv1", "golfap") #ip, user, pass, db_name
 
puts 'About to daemonize the leaderboard scraper...'
daemonize
loop do
  puts "about to update leaderboard via daemon: #{Time.now}"
  # http://www.pga.com/openchampionship/2008/scoring/index.html
  pga = PGA.new
  
  url = pga.get_urls(2009)[0]
  
  all_orphans = []
  
  puts "grabbing URL data from... #{url}"
  players = pga.friendly_structure(pga.fetch(url, true)) #fetch players 
  tourney = pga.tourney_info(url) # fetch info
  lb = Leaderboard.new(tourney, players, my_db) #ready to store
  #store tourney
  insert = lb.insert_new_event(tourney.name, 2009, tourney.dates, tourney.course, "PGA")
  players_updated = lb.store_tourney #store player data!
  lb.orphans.each{ |o| all_orphans << o}
  
  #live scoring needs to have a way to add in the current "today" to the total... and update that... so that order by will work
  # add a "live" field, order by that first, then total.  During historical scraping, "live" fields will all be null will still work
  
  a = all_orphans.uniq
  a.each{ |o| puts "orphan: #{o}"}
  sleep(90) #50 #when tourney begins
end