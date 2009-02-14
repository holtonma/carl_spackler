# Mark Holton, Jan 2009...
require 'carl_spackler'
require 'sample_store_to_db'

include CARL_SPACKLER

  pga = PGA.new
  
  url = pga.get_urls(2009)[2]
  my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name
  
  all_orphans = []
  
  puts "grabbing URL data from... #{url}"
  players = pga.friendly_structure(pga.fetch(url, true)) #fetch players 
  tourney = pga.tourney_info(url) # fetch info
  lb = Leaderboard.new(tourney, players, my_db) #ready to store
  #store tourney
  insert = lb.insert_new_event(tourney.name, 2009, tourney.dates, tourney.course, "PGA")
  players_updated = lb.store_tourney #store player data!
  lb.orphans.each{ |o| all_orphans << o}
  #puts "all_orphans: #{all_orphans.length}"

  
  a = all_orphans.uniq
  a.each{ |o| puts "orphan: #{o}"} 
  
  
