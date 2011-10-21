# Mark Holton, Jan 2009...
require '../carl_spackler'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'



class TestPlayers < Test::Unit::TestCase
  include CARL_SPACKLER

  def test_jr_III_names
    davis = Player.new("Davis Love III")
    berganio = Player.new("David Berganio Jr.")
    berganio2 = Player.new("David Berganio Jr")
    jgj = Player.new("Jim Gallagher Jr")
    chema = Player.new("Jose Maria Olazabal")

    assert_equal "Davis", davis.fname
    assert_equal "Love III", davis.lname
    assert_equal "David", berganio.fname
    assert_equal "Berganio Jr.", berganio.lname
    assert_equal "David", berganio2.fname
    assert_equal "Berganio Jr", berganio2.lname
    assert_equal "Jim", jgj.fname
    assert_equal "Gallagher Jr", jgj.lname
    assert_equal "Jose Maria", chema.fname
    assert_equal "Olazabal", chema.lname
  end

  def test_three_part_names
    maj = Player.new("Miguel Angel Jimenez")
    bdj = Player.new("Brendon de Jong")
    bvp = Player.new("Bo Van Pelt")

    assert_equal "Miguel Angel", maj.fname
    assert_equal "Jimenez", maj.lname
    assert_equal "Brendon", bdj.fname
    assert_equal "de Jong", bdj.lname
    assert_equal "Bo", bvp.fname
    assert_equal "Van Pelt", bvp.lname
  end


end
