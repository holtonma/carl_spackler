# Mark Holton, Oct 2008...
require 'carl_spackler'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'

class TestCarlSpackler < Test::Unit::TestCase
  include CARL_SPACKLER
  
  def setup
    # mocking this out to not hit the network...
    pga = open("static/alt-3.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(pga.to_html).to_s
  end
  
  def test_open_mock_file
    pga = open("static/alt-3.html") { |f| Nokogiri(f) }
    doc = Nokogiri(pga.to_html)
    assert_equal 4355, doc.to_s.length #make sure we have the correct file
    assert_equal Nokogiri::HTML::Document, doc.class
      #  everytime Nokogiri::HTML(open(url)) is called inside of 'carl_spackler' class, 
      #  return the mock sample, instead of hitting the network
  end
  
  def test_grab_players
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r005/alt-1.html"
    flexmock(pga).should_receive(:open).with(url).and_return{
      @test_leaderboard
    }
    players = pga.fetch(url) 
    puts players
  end
  
  def test_scrape_pga_tour
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r005/alt-1.html"
    # flexmock(pga).should_receive(:open).with(url).and_return{
    #   @test_leaderboard
    # }
    players = pga.fetch(url) 
    # 2008 Pebble Beach Pro-Am
    assert_equal 71, players.length
    assert_equal 12, players[0].length
    assert_equal 12, players[1].length
    # headers is row 1
    assert_equal "Pos.", players[0][1]
    assert_equal "Start", players[0][2]
    assert_equal "Player", players[0][3]
    assert_equal "Today", players[0][4]
    assert_equal "Thru", players[0][5]
    assert_equal "To Par", players[0][6]
    assert_equal "R1", players[0][7]
    assert_equal "R2", players[0][8]
    assert_equal "R3", players[0][9]
    assert_equal "R4", players[0][10]
    assert_equal "Total", players[0][11]
    # 9th player row
    assert_equal "30", players[8][0]
    assert_equal "T7", players[8][1]
    assert_equal "T3", players[8][2]
    assert_equal "Dustin Johnson (PB)", players[8][3]
    assert_equal "1", players[8][4]
    assert_equal "F", players[8][5]
    assert_equal "-6", players[8][6]
    assert_equal "73", players[8][7]
    assert_equal "68", players[8][8]
    assert_equal "68", players[8][9]
    assert_equal "73", players[8][10]
    assert_equal "282", players[8][11]
    assert_equal nil, players[8][12]
  end
  
  def test_friendly_structure
    pga = PGA.new
    url = pga.get_urls(2008)[34]
    # flexmock(pga).should_receive(:open).with(url).and_return{
    #   @test_leaderboard
    # }
    players = pga.friendly_structure(pga.fetch(url, true))
    assert_equal "Steve",  players[1].fname
    assert_equal 182, players.length
    
    # need to add more validations here
    #
  end
  
  def test_08_urls
    pga = PGA.new
    urls = pga.get_urls(2008)
    assert_equal 36, urls.length
    assert_equal 'http://www.pgatour.com/leaderboards/current/r005/alt-1.html', pga.get_urls(2008)[34]
  end
  
  def test_09_urls
    pga = PGA.new
    urls = pga.get_urls(2009)
    assert_equal 1, urls.length
    assert_equal 'http://www.pgatour.com/leaderboards/current/r016/alt-1.html', pga.get_urls(2009)[0]
  end
  
  def test_tourn_info
    pga = PGA.new
    # flexmock(pga).should_receive(:open).with(pga.get_urls(2008)[4]).and_return{
    #   @test_leaderboard
    # }
    tourney = pga.tourney_info("http://www.pgatour.com/leaderboards/current/r005/alt-1.html")
    assert_equal "AT&T Pebble Beach National Pro-Am", tourney.name
    assert_equal "Monday Feb 9 - Sunday Feb 15, 2009", tourney.dates
    assert_equal "Pebble Beach Golf Links . Pebble Beach, Calif.", tourney.course
  end
  
    
  
end
