# Mark Holton, Oct 2008...
require 'carl_spackler'
require 'sample_store_to_db'

include CARL_SPACKLER

  euro = Euro.new

  urls = euro.get_urls(2008)
  my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name

  all_orphans = []

  urls.each do |url|
    puts "grabbing URL data from... #{url}"
    players = euro.friendly_structure(euro.fetch(url, true)) #fetch players
    tourney = euro.tourney_info(url) # fetch info
    @lb = Leaderboard.new(tourney, players, my_db) #ready to store
    #store tourney
    insert = @lb.insert_new_event(tourney.name, 2008, tourney.dates, tourney.course)
    players_updated = @lb.store_tourney #store player data!
    @lb.orphans.each{ |o| all_orphans << o}
    #puts "all_orphans: #{all_orphans.length}"
  end

  a = all_orphans.uniq

  a.each do |o|
    puts "inserting... #{o.lname}, #{o.fname}"
    #@lb.insert_golfer(o.lname, o.fname)
  end


