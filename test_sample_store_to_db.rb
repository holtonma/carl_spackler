# Mark Holton, Oct 2008...
require 'carl_spackler'
require 'sample_store_to_db'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'

class TestSampleStore < Test::Unit::TestCase
  include CARL_SPACKLER 
  
  def setup
    # mocking this out to not hit the network...
    pga = open("alt-1.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(pga.to_html).to_s
    
    #invalid:
    sample = open("sample.html") { |f| Nokogiri(f) }
    @invalid_test_leaderboard = Nokogiri(sample.to_html).to_s
  end
  
  def test_extract_data
    pga = PGA.new
    flexmock(pga).should_receive(:open).with(pga.get_urls(2008)[4]).and_return{
      @test_leaderboard
    }
    
    url = pga.get_urls(2008)[38]
    assert_equal "http://www.pgatour.com/leaderboards/current/r475/alt-1.html", url 
    
    #scrape
    players = pga.friendly_structure(pga.fetch(url, true)) #incl missed cut
    tourney = pga.tourney_info(url)
    
    assert_equal 71, players.length
    assert_equal "AT&T Pebble Beach National Pro-Am", tourney.name
    assert_equal "Monday Feb 4 – Sunday Feb 10, 2008", tourney.dates
    assert_equal "Pebble Beach Golf Links · Pebble Beach, Calif.", tourney.course
    #store to database
  end
  
  def test_store_valid_tourney
    pga = PGA.new
    flexmock(pga).should_receive(:open).with(pga.get_urls(2008)[4]).and_return{
      @test_leaderboard
    }
    
    url = pga.get_urls(2008)[38]
    
    class Course 
      attr_accessor :id, :name 
      def initialize( id, name)
        @id, @name= id, name
      end
    end
    
    #scrape
    players = pga.friendly_structure(pga.fetch(url, true)) #incl missed cut
    tourney = pga.tourney_info(url)
    leaderboard = Leaderboard.new(tourney, players) 
    assert_equal 0, leaderboard.store_tourney #0 errors
  end
  
  
    
end
