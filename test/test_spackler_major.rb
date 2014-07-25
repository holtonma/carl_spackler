# Mark Holton, Oct 2008...
require '../carl_spackler'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'

class TestCarlSpackler < Test::Unit::TestCase
  include CARL_SPACKLER

  def setup
    # mocking this out to not hit the network...
    pga = open("../static/pgacom_masters2008.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(pga.to_html).to_s
  end

  def test_open_mock_file
    pga = open("../static/pgacom_masters2008.html") { |f| Nokogiri(f) }
    doc = Nokogiri(pga.to_html)
    assert_equal 67780, doc.to_s.length #make sure we have the correct file
    assert_equal Nokogiri::HTML::Document, doc.class
      #  everytime Nokogiri::HTML(open(url)) is called inside of 'carl_spackler' class,
      #  return the mock sample, instead of hitting the network
  end

  def test_grab_players
    masters = Major.new
    url = "http://www.majorschampionships.com/masters/2008/scoring/index.html"
    flexmock(masters).should_receive(:open).with(url).and_return{
      @test_leaderboard
    }
    players = masters.fetch(url)
    #puts players
    (0..20).each do |p|
      puts "#{p}: #{players[p]}"
    end
  end

  def test_scrape_pga_tour
    masters = Major.new
    url = "http://www.majorschampionships.com/masters/2008/scoring/index.html"

    players = masters.fetch(url)
    # 2008 Masters
    # playa.pos = p[0]
    # playa.mo = p[1]
    # playa.name = p[2]
    # this_player = Player.new(playa.name)
    # playa.fname = this_player.fname
    # playa.lname = this_player.lname
    # playa.to_par = p[3]
    # playa.thru = p[4]
    # playa.today = p[5]
    # playa.r1 = p[6]
    # playa.r2 = p[7]
    # playa.r3 = p[8]
    # playa.r4 = p[9]
    # playa.total = p[10]

    assert_equal 95, players.length
    assert_equal 11, players[0].length
    assert_equal 11, players[1].length
    # leader is row 1
    assert_equal "1", players[0][0]  #pos
    assert_equal "-", players[0][1] #mo
    assert_equal "Trevor Immelman", players[0][2] #name
    assert_equal "+3", players[0][5] #today
    assert_equal "F", players[0][4] #thru
    assert_equal "-8", players[0][3] #to_par
    assert_equal "68", players[0][6] #r1
    assert_equal "68", players[0][7] #r2
    assert_equal "69", players[0][8] #r3
    assert_equal "75", players[0][9] #r4
    assert_equal "280", players[0][10] #total
    # 11th player row
    assert_equal "T11", players[10][0]  #pos
    assert_equal "12", players[10][1] #mo
    assert_equal "Nick Watney", players[10][2] #name
    assert_equal "-1", players[10][5] #today
    assert_equal "F", players[10][4] #thru
    assert_equal "E", players[10][3] #to_par
    assert_equal "75", players[10][6] #r1
    assert_equal "70", players[10][7] #r2
    assert_equal "72", players[10][8] #r3
    assert_equal "71", players[10][9] #r4
    assert_equal "288", players[10][10] #total
  end

  def test_friendly_structure
    masters = Major.new
    url = masters.get_urls(2008)[0]
    # flexmock(pga).should_receive(:open).with(url).and_return{
    #   @test_leaderboard
    # }
    players = masters.friendly_structure(masters.fetch(url))
    assert_equal "Tiger",  players[1].fname
    assert_equal 94, players.length

    # need to add more validations here
    #
  end

  def test_08_urls
    masters = Major.new
    urls = masters.get_urls(2008)
    assert_equal 4, urls.length
    assert_equal 'http://www.majorschampionships.com/masters/2008/scoring/index.html', masters.get_urls(2008)[0]
  end

  def test_09_urls
    masters = Major.new
    urls = masters.get_urls(2009)
    assert_equal 4, urls.length
    assert_equal 'http://www.majorschampionships.com/masters/2009/scoring/index.html', masters.get_urls(2009)[0]
  end



end
