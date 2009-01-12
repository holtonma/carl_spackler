# Mark Holton, Oct 2008...
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
    pga_data = open("../static/alt-2.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(pga_data.to_html).to_s
    
    #invalid:
    sample = open("../static/sample.html") { |f| Nokogiri(f) }
    @invalid_test_leaderboard = Nokogiri(sample.to_html).to_s
    
    @pga = PGA.new
    flexmock(@pga).should_receive(:open).and_return{
      @test_leaderboard
    }
    @url = @pga.get_urls(2008)[38]
    my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name
    @players = @pga.friendly_structure(@pga.fetch(@url, true)) #fetch players 
    @tourney = @pga.tourney_info(@url) # fetch info
    @lb = Leaderboard.new(@tourney, @players, my_db) #ready to store
  end
  
  def test_to_ascii_iconv
    assert_equal "AT&T Pebble Beach National Pro-Am", "AT&T Pebble Beach National Pro-Am".to_ascii_iconv
    assert_equal "Pebble Beach Golf Links . Pebble Beach, Calif.", "Pebble Beach Golf Links ⋅ Pebble Beach, Calif.".to_ascii_iconv
    assert_equal "Monday Feb 4 - Sunday Feb 10, 2008", "Monday Feb 4 - Sunday Feb 10, 2008".to_ascii_iconv
  end
  
  def test_setup_data
    assert_equal "http://www.pgatour.com/leaderboards/current/r475/alt-1.html", @url 
    assert_equal 182, @players.length
    assert_equal "AT&T Pebble Beach National Pro-Am", @tourney.name
    assert_equal "Monday Feb 4 - Sunday Feb 10, 2008", @tourney.dates
    assert_equal "Pebble Beach Golf Links . Pebble Beach, Calif.", @tourney.course.to_ascii_iconv
    #store to database
  end
  
  def test_new_tourney
    #tourney slate should be blank
  end
  
  def test_name_to_id
    fname = "Tiger"
    lname = "Woods"
    
    assert_equal 94, @lb.name_to_id(fname, lname)
  end
  
  def test_eventid
    name_id = 35
    assert_equal 53, @lb.eventid(name_id) 
  end
  
  def test_get_eventnameid_from_name
    assert_equal 35, @lb.eventnameid("AT&T Pebble Beach National Pro-Am")
  end 
  
  def test_insert_new_event
    # now set a new one
    insert = @lb.insert_new_event("AT&T Pebble Beach National Pro-Am".to_ascii_iconv, 2008, 
                                  "Monday Feb 4 – Sunday Feb 10, 2008".to_ascii_iconv, 
                                  "Pebble Beach Golf Links - Pebble Beach, Calif.".to_ascii_iconv)
    # now check it
    #assert_equal 7, @lb.get_eventnameid_from_name("AT&T Pebble Beach National Pro-Am")
    assert_equal 53, insert
  end
  
  def test_check_events
    course = "Pebble Beach Golf Links · Pebble Beach, Calif.".to_ascii_iconv
    dates = "Monday Feb 4 – Sunday Feb 10, 2008".to_ascii_iconv
    tourney = "AT&T Pebble Beach National Pro-Am".to_ascii_iconv
                  
    assert_equal 0, @lb.check_event_exists(tourney, dates, course)
    # now set it
  end
  
  def test_store_valid_tourney
    pga = PGA.new
    flexmock(pga).should_receive(:open).and_return{
      @test_leaderboard
    }
    
    url = pga.get_urls(2008)[38]
    my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name
    players = pga.friendly_structure(pga.fetch(url, true)) #fetch players 
    tourney = pga.tourney_info(url) # fetch info
    lb = Leaderboard.new(tourney, players, my_db) #ready to store
    players_updated = lb.store_tourney #store data!
    
    assert_equal 182, players.length #redundant but okay
    assert_equal 180, players_updated.length
    
  end
  
  
end
