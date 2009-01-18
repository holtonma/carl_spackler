#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# license: copy this code as much as you want to
# 01-16-2009
# purpose: sample of code that uses carl_spackler to grab tournament data, and update a MySQL database
# other database schemas that differ from this one will require modifications

require 'rubygems'
require 'ostruct'
require 'iconv'
require 'active_record'

class DB 
  attr_accessor :ip, :user, :pass, :name
  def initialize(ip, user, pass, name)
    @ip, @user, @pass, @name = ip, user, pass, name
  end
end

class Leaderboard_AR
  def initialize tourney, players, db 
    @tourney = tourney
    @players = players
    @db = db #ip, user, pass, db, ...
    @num_inserts = 0
    @event_id = self.eventid(self.eventnameid(@tourney.name), Time.now.year) #lame, need to improve this
    @orphans = [] #players not matched
  end
  
  attr_accessor :tourney, :players, :num_inserts, :orphans
    
  
  
end






