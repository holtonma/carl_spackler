# Mark Holton, Oct 2008...
require 'carl_spackler'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'

class TestCarlSpackler < Test::Unit::TestCase
  include CARL_SPACKLER
  
  def setup
    # mocking this out to not hit the network...
    pga = open("sample.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(pga.to_html).to_s
  end
  
  def test_open_mock_file
    pga = open("sample.html") { |f| Nokogiri(f) }
    doc = Nokogiri(pga.to_html)
    assert_equal 79180, doc.to_s.length #make sure we have the correct file
    assert_equal Nokogiri::HTML::Document, doc.class
      #  everytime Nokogiri::HTML(open(url)) is called inside of 'carl_spackler', 
      #  return the mock sample, instead of hitting the network
  end
  
  def test_scrape_pga_tour
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r045/alt-1.html"
    flexmock(pga).should_receive(:open).with(url).and_return{
      @test_leaderboard
    }
    players = pga.fetch(url) 
    assert_equal 50, players.length
    assert_equal 1, players[0].rank
    assert_equal "Tiger", players[0].fname
    assert_equal "Woods", players[0].lname
  end
  
  def test_friendly_structure
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r045/alt-1.html"
    flexmock(pga).should_receive(:open).with(url).and_return{
      @test_leaderboard
    }
    players = pga.friendly_structure(pga.fetch(url, true))
    #players.each do |p|
      #puts "#{p.pos} :: [#{p.name}] #{p.fname} #{p.lname} #{p.start} #{p.thru} #{p.to_par} (#{p.r1} #{p.r2} #{p.r3} #{p.r4})"
    #end
    assert_equal "bite me",  players[1].fname
    assert_equal 130, players.length
  end
  
  def test_mercedes
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r060/alt-1.html"
    flexmock(pga).should_receive(:open).with(url).and_return{
      @test_leaderboard
    }
    players = pga.friendly_structure(pga.fetch(url, true))
    #players.each do |p|
      #puts "#{p.pos} :: [#{p.name}] #{p.fname} #{p.lname} #{p.start} #{p.thru} #{p.to_par} (#{p.r1} #{p.r2} #{p.r3} #{p.r4})"
    #end
    assert_equal "foo bar baz",  players[1].fname
    assert_equal 31, players.length
  end
  
  def test_08_urls
    pga = PGA.new
    urls = pga.get_urls(2008)
    assert_equal 8, urls.length
    assert_equal 'http://www.pgatour.com/leaderboards/current/r005/alt-1.html', pga.get_urls(2008)[4]
  end
  
  def test_tourn_info
    pga = PGA.new
    flexmock(pga).should_receive(:open).with(pga.get_urls(2008)[4]).and_return{
      @test_leaderboard
    }
    tourney = pga.tourney_info(pga.get_urls(2008)[4])
    assert_equal "AT&T Pebble Beach National Pro-Am", tourney.name
    assert_equal "Monday Feb 4 – Sunday Feb 10, 2008", tourney.dates
    assert_equal "Pebble Beach Golf Links · Pebble Beach, Calif.", tourney.course
  end
  
  
end
