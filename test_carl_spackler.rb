
require 'carl_spackler'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'stringio'
require 'ostruct'

class TestOGWR < Test::Unit::TestCase
  include CARL_SPACKLER
  
  def setup
    # i really should mock this out and not hit the network... will do that later
    # page = 1
    # url = "http://www.officialworldgolfranking.com/rankings/default.sps?region=world&PageCount=#{page}"
    # flexmock(fetcher).should_receive(:open).with(url, page).and_return{
    #   File.open(sample.html, 'r') 
    # }
  end
  
  def test_scrape_pga_tour
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r045/alt-1.html"
    players = pga.fetch(url) 
    #assert_equal 50, players.length
    #assert_equal 1, players[0].rank
    #assert_equal "Tiger", players[0].fname
    #assert_equal "Woods", players[0].lname
  end
  
  def test_friendly_structure
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r045/alt-1.html"
    players = pga.friendly_structure(pga.fetch(url, true))
    players.each do |p|
      puts "#{p.pos} :: [#{p.name}] #{p.fname} #{p.lname} #{p.start} #{p.thru} #{p.to_par} (#{p.r1} #{p.r2} #{p.r3} #{p.r4})"
    end
    puts "first player fname:  #{players[1].fname}"
    #puts players
    assert_equal 130, players.length
  end
  
  def test_mercedes
    pga = PGA.new
    url = "http://www.pgatour.com/leaderboards/current/r060/alt-1.html"
    players = pga.friendly_structure(pga.fetch(url, true))
    players.each do |p|
      puts "#{p.pos} :: [#{p.name}] #{p.fname} #{p.lname} #{p.start} #{p.thru} #{p.to_par} (#{p.r1} #{p.r2} #{p.r3} #{p.r4})"
    end
    puts "first player fname:  #{players[1].fname}"
    #puts players
    assert_equal 31, players.length
  end
  
  
  
  
end
