# Mark Holton, Oct 2008...
require 'carl_spackler'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'

class TestCarlSpackler < Test::Unit::TestCase
  include CARL_SPACKLER
  
  def setup
    # mocking this out to not hit the network...
    euro = open("euro_sample1.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(euro.to_html).to_s
  end
  
  def test_open_mock_file
    euro = open("euro_sample1.html") { |f| Nokogiri(f) }
    doc = Nokogiri(euro.to_html)
    assert_equal 117399, doc.to_s.length #make sure we have the correct file
    assert_equal Nokogiri::HTML::Document, doc.class
      #  everytime Nokogiri::HTML(open(url)) is called inside of 'carl_spackler' class, 
      #  return the mock sample, instead of hitting the network
  end
  
  def test_scrape_euro_tour
    euro = Euro.new
    url = euro.get_urls(2008)[0]
    flexmock(euro).should_receive(:open).with(url).and_return{
      @test_leaderboard
    }
    players = euro.fetch(url) 
        
    assert_equal 75, players.length
    
    assert_equal 10, players[5].length
    assert_equal 10, players[7].length
    
    # 7th player row
    row = 7
    assert_equal "T8", players[row][0] #start
    assert_equal "T8", players[row][1] #pos
    assert_equal "MARKSAENG, Prayad", players[row][2] #name
                                     # [3] is image
    assert_equal "18", players[row][4] # Thru (Hole)
    assert_equal "-9", players[row][5] # to_par
    assert_equal "68", players[row][6] # r1
    assert_equal "70", players[row][7] # r2
    assert_equal "71", players[row][8] # r3
    assert_equal "70", players[row][9] # r4
    assert_equal nil, players[row][10] 
    assert_equal nil, players[row][11]
    assert_equal nil, players[row][12]
    
  end
  
  def test_friendly_structure
    euro = Euro.new
    url = euro.get_urls(2008)[0]
    flexmock(euro).should_receive(:open).with(url).and_return{
      @test_leaderboard
    }
    players = euro.friendly_structure(euro.fetch(url, true))
    assert_equal "Oliver",  players[1].fname
    assert_equal 75, players.length
    assert_equal "GARCIA",  players[0].lname
    assert_equal "Sergio",  players[0].fname
    assert_equal "1", players[0].pos
    assert_equal "T3", players[0].start
    assert_equal "18", players[0].thru
    assert_equal "-14", players[0].to_par
    assert_equal "66", players[0].r1
    assert_equal "68", players[0].r2
    assert_equal "72", players[0].r3
    assert_equal "68", players[0].r4
    assert_equal "274", players[0].total
    
    # need to add more validations here
    #
  end
  
  def test_08_urls
    euro = Euro.new
    urls = euro.get_urls(2008)
    assert_equal 39, urls.length
    assert_equal URI.escape('http://scores.europeantour.com/default.sps?pagegid={9FFD4839-08EC-4F90-85A2-10F94D42CDB2}&eventid=2008091&ieventno=2008088&infosid=2'), 
      euro.get_urls(2008)[0]
  end
  
  def test_tourn_info
    euro = Euro.new
    # flexmock(euro).should_receive(:open).with(euro.get_urls(2008)[0]).and_return{
    #   @test_leaderboard
    # }
    tourney = euro.tourney_info(euro.get_urls(2008)[0])
    assert_equal "HSBC Champions", tourney.name
    assert_equal "06 Nov 2008  - 09 Nov 2008", tourney.dates
    assert_equal "Sheshan International GC", tourney.course
    assert_equal "Shanghai,\r\n            China", tourney.local #need to strip out /r/n and spaces
  end  
  
end
