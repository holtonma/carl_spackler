#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# license: copy this code as much as you want to
# 11-25-2008
# purpose: sample of code that uses carl_spackler to grab tournament data, and update a MySQL database
# other database schemas that differ from this one will require modifications

require 'rubygems'
require 'mysql'
require 'ostruct'
require 'iconv'

class DB 
  attr_accessor :ip, :user, :pass, :name
  def initialize(ip, user, pass, name)
    @ip, @user, @pass, @name = ip, user, pass, name
  end
end

class Leaderboard
  def initialize tourney, players, db 
    @tourney = tourney
    @players = players
    @db = db #ip, user, pass, db, ...
    @num_inserts = 0
    @event_id = self.eventid(self.eventnameid(@tourney.name), Time.now.year) #lame, need to improve this
    @orphans = [] #players not matched
  end
  
  attr_accessor :tourney, :players, :num_inserts, :orphans
    
  def name_to_id(fname, lname)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    first = dbh.escape_string(fname)
    last = dbh.escape_string(lname)
    q_name = dbh.query("SELECT id FROM golfer WHERE fname = '#{first}' AND lname = '#{last}' ORDER BY id DESC")
    golfer_id = -1
    q_name.each do |row|
       golfer_id = row[0]
    end
    
    # check altnernate names:
    # TBD
    
    if golfer_id == -1 || golfer_id == 0
      # orphan = {}
      # orphan[:time] = Time.now
      # orphan[:fname] = fname
      # orphan[:lname] = lname
      unless lname.strip =~ /'/ #i don't want to collect player names for now with '
        orphan = OpenStruct.new
        orphan.lname = lname.strip()
        orphan.fname = fname.strip()
        #orphan = "#{lname}, #{fname}"
        @orphans << orphan
      end
    end
    
    golfer_id.to_i
  end
  
  def check_event_exists(name, date_str, course_str)
    # check event to see if: name, dates, course exists
    # => yes: skip to next URL
    # => no: insert row into 'events' table
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    tourney = name #dbh.escape_string(name)
    dates = dbh.escape_string(date_str)
    course_name = course_str #dbh.escape_string(course_str)
    
    q_check = dbh.query("SELECT id FROM events
        WHERE name = '#{tourney}'
        AND dates = '#{dates}'
        AND course = '#{course_name}'
        AND scraped = 1")
    records = q_check.num_rows()
    q_check.free
    
    records #0 means no rows... 1 = exists
  end
  
  
  def eventnameid(event_name)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    tourney = event_name #dbh.escape_string(event_name)
    q = dbh.query("SELECT id FROM event_names
        WHERE name = '#{tourney}'
        ")
        
    event_name_id = 0
    
    if q.num_rows() == 1
      q.each{ |row| event_name_id = row[0] }
    end
    
    event_name_id.to_i
  end
  
  def eventid(event_name_id, year)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    q = dbh.query("SELECT id FROM events WHERE name_id = '#{event_name_id.to_i}' AND year = #{year}")
        
    event_name_id = 0
    q.each{ |row| event_name_id = row[0] }
    
    event_name_id.to_i
  end  
  
  def insert_new_event(name, year, dates, course, tour="PGA")
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    
    # check event_names:
    name_id = self.eventnameid(name)
    if name_id == 0 # doesn't exist in event_names
        q = dbh.query("INSERT INTO event_names (name) VALUES ('#{name}') ")
        name_id = self.eventnameid(name)
    end
    
    # check events, and return event_id after insert (or return existing):
    event_id = self.eventid(name_id, year)
    @q_check = dbh.query("SELECT id FROM events WHERE name_id = '#{name_id}' AND year = #{year}")
    
    if event_id == 0 # doesn't exist in events:
      q2 = dbh.query("INSERT INTO events (name_id, year, name, dates, course, scraped)
          VALUES(#{name_id}, #{year}, '#{name}', '#{dates}', '#{course}', 0)")
      return self.eventid(name_id, year)
    else
      return event_id
    end    
  end
  
  def golfer_in_tournament_status(p, event_id)
    playa_id = self.name_to_id(p.fname, p.lname)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    # how this will be consumed:
    # 0 -- insert
    # 1 -- update
    # > 1 -- do nothing
    dbh.query("SELECT id FROM golfer_history WHERE golfer_id = '#{playa_id}' AND event_id = #{event_id}").num_rows()
  end
    
  def store_player(p, event_id, made_cut)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    in_tourney = self.golfer_in_tournament_status(p, event_id)
    g_id = self.name_to_id(p.fname, p.lname)
    if in_tourney == 0 && g_id > 0# insert  ------- '#{p.thru}'
      insert_query = "INSERT INTO golfer_history(golfer_id, to_par, today, money, pos, madecut, thru, event_id, r1, r2, r3, r4, total) 
                  VALUES (#{g_id}, '#{p.to_par}', '#{p.today}', '#{p.money}', '#{p.pos}', #{made_cut}, '#{p.thru}', #{event_id}, '#{p.r1}', '#{p.r2}', '#{p.r3}',
                  '#{p.r4}', '#{p.total}')"
      #puts insert_query
      puts "#{p.lname}, #{p.fname} inserted (event_id: #{event_id})."
      dbh.query(insert_query)
    elsif in_tourney == 1 && g_id > 0# update
      update_query = "UPDATE golfer_history SET to_par = '#{p.to_par}', today = '#{p.today}', money = '#{p.money}', pos = '#{p.pos}', 
                  madecut = 1, thru = '#{p.thru}', r1 = '#{p.r1}', r2 = '#{p.r2}', r3 = '#{p.r3}', r4 = '#{p.r4}', total = '#{p.total}'
                  WHERE golfer_id = #{g_id} AND event_id = #{event_id}"
      #puts update_query
      puts "#{p.lname}, #{p.fname} updated (event_id: #{event_id})."
      dbh.query(update_query)
    else
      # > 1 means something strange, so don't do anything
    end
    
    q_history_id = dbh.query("SELECT id FROM golfer_history WHERE golfer_id = #{g_id} AND event_id = #{event_id}")
    history_id = -1
    q_history_id.each do |row|
       history_id = row[0]
    end
    dbh.close
    history_id.to_i
    # return id in golfer_history created or updated
  end
  
  
  def store_tourney
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    made_cut = 1
    ids_stored = []
    @players.each do |p|
      ids_stored << self.store_player(p, @event_id, 1) unless p.thru == 'Thru'
      #puts "#{p.pos} :: #{p.name} #{p.fname} #{p.lname} #{p.r1} #{p.r2} #{p.r3} #{p.r4} #{p.start} #{p.thru} #{p.to_par}"
    end
    
    ids_stored
  end
  
  def check_golfer_exists(last_name, first_name)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    first = dbh.escape_string(first_name.strip())
    last = dbh.escape_string(last_name.strip())
    
    puts "first: #{first} last:#{last}"
    q_string = "SELECT id FROM golfer WHERE lname = '#{last}' AND fname = '#{first}'"
    puts q_string
    dbh.query(q_string).num_rows()
  end
  
  def insert_golfer(last_name, first_name)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    if last_name == nil || last_name == "" || first_name == "" || first_name == nil
      return "not inserted: nil or '' in one of names"
    else
      
      first = dbh.escape_string(first_name.strip())
      last = dbh.escape_string(last_name.strip())
      
      exists_val = self.check_golfer_exists(last, first)
      if exists_val == 0 #player doesn't yet exist in db, therefore insert him
      
        dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
      
        q2 = dbh.query("INSERT INTO golfer (fname, lname, degs_of_wally, image, active, madecut, thru, event_id, position)
            VALUES('#{first}', '#{last}', 2, 'qualifier', 0, 0, '-', 0, '-')")
          
        return "inserted #{last}, #{first}"
      end
    end
  end
  
  def update_cut(event_id)
    dbh = Mysql.real_connect(@db.ip, @db.user, @db.pass, @db.name)
    
    q_string = "update golfer_history set madecut = -1 where event_id = #{event_id} and thru = '--'"
    dbh.query(q_string)
    
  end
  
  
  
  
end






