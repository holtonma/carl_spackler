#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# license: copy this code as much as you want to
# 11-25-2008
# purpose: sample of code that uses carl_spackler to grab tournament data, and update a MySQL database
# other database schemas that differ from this one will require modifications

require 'rubygems'
require 'mysql'

class Leaderboard
  def initialize file_or_url, root_path, leaderboard_path=""
    @file_or_url = file_or_url
    @root_path = root_path
    @leaderboard_path = leaderboard_path
    @leaders = []
  end
  
  attr_accessor :root_path, :leaderboard_path, :leaders
  
  def split_name full_name
    names = {}
    split_names = full_name.split(" ")
    if split_names.length == 3
      names[:first] = split_names[0]
      names[:last] = "#{split_names[1]} #{split_names[2]}" #jr., sr., III, etc
    else
      names[:first] = split_names[0]
      names[:last] = split_names[1]
    end
    
    names
  end
  
  def update_db(scraped_name, current_score, thru)
    # playa.money = p[0]
    # playa.pos = p[1]
    # playa.start = p[2]
    # playa.name = p[3]
    # playa.fname = p[3].split(" ")[0] #need to improve this
    # playa.lname = p[3].split(" ")[1] #need to improve this
    # playa.today = p[4]
    # playa.thru = p[5]
    # playa.to_par = p[6]
    # playa.r1 = p[7] 
    # playa.r2 = p[8]
    # playa.r3 = p[9]
    # playa.r4 = p[10]
    # playa.total = p[11]
   
   dbh = Mysql.real_connect("localhost", "testuser", "testpass", "golfap")
   
   q_preupdate = dbh.query("SELECT CurrentScoreRelPar, GolferFirstName, GolferLastName 
     FROM tgolfer WHERE GolferFirstName = '#{first_name}' 
     AND GolferLastName = '#{last_name}'")
   if q_preupdate.num_rows == 1
     q_update = dbh.query("UPDATE tgolfer SET CurrentScoreRelPar = #{current_score} 
     WHERE GolferFirstName = '#{first_name}' 
     AND GolferLastName = '#{last_name}'")
     q_getupdate = dbh.query("SELECT CurrentScoreRelPar, GolferFirstName, GolferLastName 
     FROM tgolfer WHERE GolferFirstName = '#{first_name}' 
     AND GolferLastName = '#{last_name}'")
     q_getupdate.each do |row|
       printf "%s, %s, %s\n", row[0], row[1], row[2]
     end
     q_getupdate.free
     q_preupdate.free
   else
     puts "no match with : #{scraped_name}, therefore inserting new..."
     q_insert = dbh.query("INSERT INTO tgolfer (GolferFirstName, 
       GolferLastName, CurrentScoreRelPar, DegsofWallyVal, 
       GolferImage, active, madecut, thru) 
       VALUES ('#{first_name}', '#{last_name}', 0, 2, 'qualifier.gif', 1, 0, 0)")
   end
   dbh.close if dbh #disconnect
  end
  
  def update_all_leaders leaders
    leaders.each do |player|
      update_db(player[:player], player[:to_par], player[:thru])
    end
  end
  
  
end






