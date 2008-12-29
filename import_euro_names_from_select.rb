# Mark Holton, Dec 2008...
require 'carl_spackler'
require 'sample_store_to_db'

include CARL_SPACKLER

  euro = Euro.new
  
  my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name
  tourney = OpenStruct.new
  tourney.name = "foobarbaz"
  @tourney = tourney
  @players = []
  @lb = Leaderboard.new(@tourney, @players, my_db) #ready to store
  
  
  # open stubbed doc (with Select and with Options)
  # extract all option elements
  # loop through them
  # golfers.each do |g| #g = "Lname, Fname
  #   g.
  #   @lb.insert_golfer(lname, fname)
  #   exists = @lb.check_golfer_exists("Holtonomo", "Mark")
  #   
  # end
  
  
  
