# Mark Holton, Oct 2008...
require 'carl_spackler'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'

class TestCarlSpackler < Test::Unit::TestCase
  include CARL_SPACKLER

  def setup
    # mocking this out to not hit the network...
    pga = open("alt-3.html") { |f| Nokogiri(f) }
    @test_leaderboard = Nokogiri(pga.to_html).to_s
  end

  def test_open_mock_file
    pga = open("alt-3.html") { |f| Nokogiri(f) }
    doc = Nokogiri(pga.to_html)
    assert_equal 4355, doc.to_s.length #make sure we have the correct file
    assert_equal Nokogiri::HTML::Document, doc.class
      #  everytime Nokogiri::HTML(open(url)) is called inside of 'carl_spackler' class,
      #  return the mock sample, instead of hitting the network
  end

  def test_grab_players
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r005/alt-1.html"

    players = pga.fetch(url)

    players = pga.friendly_structure(pga.fetch(url, true))

  end





end
