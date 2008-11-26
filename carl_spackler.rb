#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# copy as much as you want to
# 10-29-2008
# purpose: scrape the golf tournament scores, and present it in a more usable form (Array of ostruct's)
# using Hpricot, open-uri

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'ostruct'

module CARL_SPACKLER
  VERSION = '0.1.0'

  class PGA
    
    def get_urls(year)
      # html data urls for 2008 (only 4 round tournaments included)
      if year == 2008
        urls = %w(
          http://www.pgatour.com/leaderboards/current/r475/alt-1.html
          http://www.pgatour.com/leaderboards/current/r010/alt-1.html
          http://www.pgatour.com/leaderboards/current/r457/alt-1.html
          http://www.pgatour.com/leaderboards/current/r007/alt-1.html
          http://www.pgatour.com/leaderboards/current/r005/alt-1.html
          http://www.pgatour.com/leaderboards/current/r003/alt-1.html
          http://www.pgatour.com/leaderboards/current/r004/alt-1.html
          http://www.pgatour.com/leaderboards/current/r060/alt-1.html
        )
      elsif year == 2007
        urls = []
      else
        urls = []
      end
      
      urls
    end
    
    def tourney_info(url)
      # tournament name
      # tournament dates
      # golf course
      # location
        # <div class="tourTournSubName">Mayakoba Golf Classic at Riviera Maya-Cancun</div>
        # <div class="tourTournNameDates">Thursday Feb 21 – Sunday Feb 24, 2008</div>
        # <div class="tourTournHeadLinks">El Camaleon Golf Club · Playa del Carmen, Quintana Roo, Mexico</div>
        # <div class="tourTournLogo">
        #   <img src="/.element/img/3.0/sect/tournaments/r457/tourn_logo.gif"/>
        # </div>
        doc = Nokogiri::HTML(open(url))
        tourn = OpenStruct.new
        tourn.name = doc.css('div.tourTournSubName').first.inner_text.strip()
        tourn.dates = doc.css('div.tourTournNameDates').first.inner_text.strip()
        tourn.course = doc.css('div.tourTournHeadLinks').first.inner_text.strip()
        #puts "tourn name: #{doc.css('div.tourTournSubName').first.inner_text.strip()}"
        tourn
    end
    
    def fetch(url, incl_missed_cut=false)
      doc = Nokogiri::HTML(open(url))
      
      player_data = []
      cells = []
            
      #made cut
      doc.css('table.altleaderboard').each do |table|
        if table.attributes['class'] == 'altleaderboard'
          table.css('tr').each do |row|
            row.css('td').each do |cel|
              innertext = cel.inner_text.strip()
              cells << innertext
            end
            player_data << cells
            cells = []
          end
        end
      end
      
      if incl_missed_cut
        doc.css('table.altleaderboard2').each do |table|
          #puts table
          #puts lb.inner_text
          if table.attributes['class'] == 'altleaderboard2'
            table.css('tr').each do |row|
              row.css('td').each do |cel|
                innertext = cel.inner_text.strip()
                cells << innertext
              end
              player_data << cells
              cells = []
            end
          end
        end 
      end   
      
      player_data
    end
    
    def friendly_structure player_data
      # PGA cells:
      # Pos.    0
      # Start   1
      # Player  2
      # Today   3
      # Thru    4
      # To Par  5
      # R1      6
      # R2      7
      # R3      8
      # R4      9
      # Total  10
      
      # take player_data and turn it into array of Ostructs
      players = []
      player_data.each do |p|
        next unless (p.length > 0 && p[0] != "Pos")
        playa = OpenStruct.new
        playa.money = p[0]
        playa.pos = p[1]
        playa.start = p[2]
        playa.name = p[3]
        playa.fname = p[3].split(" ")[0]
        playa.lname = p[3].split(" ")[1]
        playa.today = p[4]
        playa.thru = p[5]
        playa.to_par = p[6]
        playa.r1 = p[7] #p[6]
        playa.r2 = p[8]
        playa.r3 = p[9]
        playa.r4 = p[10]
        playa.total = p[11]
        players << playa
      end
      
      players
    end
    
  end
  
end






