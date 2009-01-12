# Mark Holton, Oct 2008...
require '../carl_spackler'
require '../sample_store_to_db'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'

require 'mysql'
require 'ostruct'


class TestCarlSpackler < Test::Unit::TestCase
  include CARL_SPACKLER
  
  def setup
    # mocking this out to not hit the network...
    my_db = DB.new("127.0.0.1", "root", "", "tour_data") #ip, user, pass, db_name
    tourney = OpenStruct.new
    tourney.name = "foobarbaz"
    @tourney = tourney
    @players = []
    @lb = Leaderboard.new(@tourney, @players, my_db) #ready to store
  end
  
  def test_check_golfer_exists
    exists = @lb.check_golfer_exists("Holtonomo", "Mark")
    assert_equal 0, exists
    exists2 = @lb.check_golfer_exists("OTTO", "Hennie")
    puts "exists2: #{exists2}"
    assert_equal 1, exists2
  end
  
  def test_insert_golfer
    foo = @lb.insert_golfer("Button", "Benjamin")
    exists2 = @lb.check_golfer_exists("Button", "Benjamin")
    assert_equal 1, exists2
    foo2 = @lb.insert_golfer("BOURDY", "Grégory")
    exists3 = @lb.check_golfer_exists("BOURDY", "Grégory")
    assert_equal 1, exists3
    foo4 = @lb.insert_golfer("FDEZ-CASTAÑO", "Gonzalo")
    exists4 = @lb.check_golfer_exists("FDEZ-CASTAÑO", "Gonzalo")
    assert_equal 1, exists4
    
    
  end
  
end
