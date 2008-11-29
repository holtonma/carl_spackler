#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# license: copy this code as much as you want to
# 10-29-2008
# purpose: scrape the golf tournament scores, and present it in a more usable form (Array of ostruct's)
# using nokogiri, open-uri

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'ostruct'

module CARL_SPACKLER
  VERSION = '0.3.0'

  class PGA
    
    def get_urls(year)
      if year == 2008
        # html data urls for 2008 
        tourneys = %w(
                r010 r457 r007 r005 r003 r004 r060 r483 r473 r018 r020
                r012 r019 r480 r022 r021 r023 r025 r034 r035 r471 r029
                r030 r032 r472 r476 r013 r027 r505 r028 r060 r054 r481 
                r041 r047 r464 r482 r045 r475
                )
        urls = []
        #http://www.pgatour.com/leaderboards/current/r475/alt-1.html :=> build all urls
        tourneys.each do |t|
          urls << "http://www.pgatour.com/leaderboards/current/#{t}/alt-1.html"
        end
      elsif year == 2007
        urls = []
      else
        urls = []
      end
      
      urls
    end
    
    def tourney_info(url)
      # tournament name, dates, golf course, location
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
        #tourn.img = doc.css('div.tourTournLogo').first.inner_html
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
      # take player_data and turn it into array of Ostructs
      players = []
      player_data.each do |p|
        next unless (p.length > 0 && p[0] != "Pos")
        playa = OpenStruct.new
        # extract data from PGA cells:
        playa.money = p[0]
        playa.pos = p[1]
        playa.start = p[2]
        playa.name = p[3]
        playa.fname = p[3].split(" ")[0] #need to improve this
        playa.lname = p[3].split(" ")[1] #need to improve this
        playa.today = p[4]
        playa.thru = p[5]
        playa.to_par = p[6]
        playa.r1 = p[7] 
        playa.r2 = p[8]
        playa.r3 = p[9]
        playa.r4 = p[10]
        playa.total = p[11]
        players << playa
      end
      
      return players
    end
    
    def to_screen
      # if tourney info and players defined, output them to screen,
      
      #players.each do |p|
        #puts "#{p.pos} :: [#{p.name}] #{p.fname} #{p.lname} #{p.start} #{p.thru} #{p.to_par} (#{p.r1} #{p.r2} #{p.r3} #{p.r4})"
      #end
      to_screen_output = " some screen output here ...."
      # otherwise grab info, then output to screen
      to_screen_output
    end
    
    
  end #end class PGA
  
  class Euro
  end
  
  class Nationwide
  end
  
end






