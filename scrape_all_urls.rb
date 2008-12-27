# Mark Holton, Oct 2008...
require 'carl_spackler'
require 'sample_store_to_db'

include CARL_SPACKLER

  pga = PGA.new
  
  pga_data = open("alt-2.html") { |f| Nokogiri(f) }
  @test_leaderboard = Nokogiri(pga_data.to_html).to_s
    
  urls = pga.get_urls(2008)
  my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name
  #my_db = DB.new("76.12.19.132", "golfap", "Aviaryv1", "golfap") 
  
  #test_urls = []
  #test_urls << pga.get_urls(2008)[1]
  
  all_orphans = []
  
  urls.each do |url|
    puts "grabbing URL data from... #{url}"
    players = pga.friendly_structure(pga.fetch(url, true)) #fetch players 
    tourney = pga.tourney_info(url) # fetch info
    lb = Leaderboard.new(tourney, players, my_db) #ready to store
    #store tourney
    insert = lb.insert_new_event(tourney.name, 2009, tourney.dates, tourney.course)
    players_updated = lb.store_tourney #store player data!
    lb.orphans.each{ |o| all_orphans << o}
    #puts "all_orphans: #{all_orphans.length}"
  end
  
  a = all_orphans.uniq
  
  a.each{ |o| puts "orphan: #{o}"} 
  
  
