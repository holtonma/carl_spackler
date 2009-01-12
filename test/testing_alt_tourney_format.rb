# Mark Holton, Dec 2008...
require '../carl_spackler'
require '../sample_store_to_db'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'


class TestSampleStore < Test::Unit::TestCase
  include CARL_SPACKLER
  
  def setup
    # mocking this out to not hit the network...
    #pga_data = open("alt-1.html") { |f| Nokogiri(f) }
    pga_data = open("../static/alt-r505.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(pga_data.to_html).to_s
    
    #invalid:
    sample = open("../static/sample.html") { |f| Nokogiri(f) }
    @invalid_test_leaderboard = Nokogiri(sample.to_html).to_s
    
    @pga = PGA.new
    flexmock(@pga).should_receive(:open).and_return{
      @test_leaderboard
    }
    @url = @pga.get_urls(2008)[38]
    @my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name
    @players = @pga.friendly_structure(@pga.fetch(@url, true)) #fetch players 
    @tourney = @pga.tourney_info(@url) # fetch info
    @lb = Leaderboard.new(@tourney, @players, @my_db) #ready to store
  end
  
  def test_store_a_feckin_alt_tourney
    puts "grabbing URL data from... #{@url}"
    players = @pga.friendly_structure(@pga.fetch(@url, true)) #fetch players 
    tourney = @pga.tourney_info(@url) # fetch info
    lb = Leaderboard.new(@tourney, @players, @my_db) #ready to store
    #store tourney
    insert = lb.insert_new_event(@tourney.name, 2009, @tourney.dates, @tourney.course)
    players_updated = lb.store_tourney #store player data!
    lb.orphans.each{ |o| all_orphans << o}
  end
  
  
end
