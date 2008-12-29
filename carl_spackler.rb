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
require 'iconv'

#monkey patch String to remove any non-ASCII characters from scrapeage
class String
  def to_ascii_iconv
    converter = Iconv.new('ASCII//IGNORE//TRANSLIT', 'UTF-8')
    converter.iconv(self).unpack('U*').select{ |cp| cp < 127 }.pack('U*')
  end
end

module CARL_SPACKLER
  VERSION = '0.6.0'

  class PGA
        
    def get_urls(year)
      if year == 2008
        # diff format: r476 
        # html data urls for 2008  
        urls = %w(
                  r045 r060 r505 r029 r032 r028 r020 r480 r023 r034 r035 r030
                  r003 r004 r483 r018 r054 r481 r012 r019 r022 r021 r025 r471 
                  r472 r013 r041 r047 r464 r482 r475 r010 r457 r007 r005 r027 
                ).map { |t|
                  "http://www.pgatour.com/leaderboards/current/#{t}/alt-1.html"
                }
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
        
        #array of hash literals for those that can't be scraped 
        tourn_misfits = [
          {:name => "The Barclays"},
          {:name => "BMW Championship"},
          {:name => "The Tour Championship"},
          {:name => "Deutsche Bank Championship"}
        ]
        
        # div.tourTourSubName not defined
        if doc.css('div.tourTournSubName').first == nil
          # name doesn't exist in markup, therefore lookup in hash
          if url == "http://www.pgatour.com/leaderboards/current/r027/alt-1.html"
            tourn.name = tourn_misfits[0][:name]
          elsif url == "http://www.pgatour.com/leaderboards/current/r028/alt-1.html"
            tourn.name = tourn_misfits[1][:name]
          elsif url == "http://www.pgatour.com/leaderboards/current/r060/alt-1.html"
            tourn.name = tourn_misfits[2][:name]
          elsif url == "http://www.pgatour.com/leaderboards/current/r505/alt-1.html"
            tourn.name = tourn_misfits[3][:name]
          end
        else
          tourn.name = doc.css('div.tourTournSubName').first.inner_text.strip().to_ascii_iconv.gsub!(/'/, "")
        end   
        
        if doc.css('div.tourTournNameDates').first == nil
          #some leaderboards have different formats:
          tourn.dates = doc.css('div.tourTournSubInfo').first.inner_text.strip().to_ascii_iconv.split(' . ')[0]
          tourn.course = doc.css('div.tourTournSubInfo').first.inner_text.strip().to_ascii_iconv.split(' . ')[1].gsub!(/'/, "")
          #puts tourn.dates #puts tourn.course
        else
          tourn.dates = doc.css('div.tourTournNameDates').first.inner_text.strip().to_ascii_iconv #unless doc.css('div.tourTournNameDates') == nil 
          tourn.course = doc.css('div.tourTournHeadLinks').first.inner_text.strip().to_ascii_iconv.gsub!(/'/, "") #unless doc.css('div.tourTournHeadLinks') == nil
          #tourn.img = doc.css('div.tourTournLogo').first.inner_html
        end
        
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
              cells << innertext.to_ascii_iconv
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
                innertext = cel.inner_text.strip().to_ascii_iconv
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
    
  end #end class PGA
  
  class Euro
    
    def get_urls(year)
      if year == 2008
        # Euro Tour links        
        # not working: 2008020 2008026 2008086' in name:
        urls = %w(
                  2008091 2008093 2008094 2008096 2008098 2008002 2008004 2008006 2008008 2008014
                  2008016 2008018 2008024 2008028 2008032 2008034 2008036 2008038 
                  2008040 2008042 2008044 2008046 2008050 2008052 2008054 2008056 2008062 2008068 
                  2008070 2008072 2008074 2008076 2008078 2008083 2008084 2008088
                ).map { |t|
                  #get rid of ugly assed pageid brackets
                  URI.escape("http://scores.europeantour.com/default.sps?pagegid={9FFD4839-08EC-4F90-85A2-10F94D42CDB2}&eventid=#{t}&ieventno=2008088&infosid=2")
                }
      elsif year == 2007
        urls = []
      else
        urls = []
      end
      
      urls
    
    end
    
    def tourney_info(url)
      # tournament name, dates, golf course, location
        # <div id = "tournHeaderDiv">Commercialbank Qatar Masters presented by Dolphin Energy</div>
        # <div id = "tournVenue">Doha G.C.</div>
        # <div id = "tournLocal">Doha, Qatar</div>
        # <div id = "tournHeaderDate">24 Jan 2008  - 27 Jan 2008 </div>
        
        doc = Nokogiri::HTML(open(url))
        
        tourn = OpenStruct.new
        
        tourn.name = doc.css('div#tournHeaderDiv').first.inner_text.strip().to_ascii_iconv  
        tourn.course = doc.css('div#tournVenue').first.inner_text.strip().to_ascii_iconv
        tourn.dates = doc.css('div#tournHeaderDate').first.inner_text.strip().to_ascii_iconv
        tourn.local = doc.css('div#tournLocal').first.inner_text.strip().to_ascii_iconv
         
        tourn
    end
    
    def fetch(url, incl_missed_cut=false)
      doc = Nokogiri::HTML(open(url))
      
      player_data = []
      cells = []
            
      #made cut and missed cut
      doc.css('div#scoresBoard2 table')[0].css('tr').each do |row|
        row.css('td').each do |cel|
          cells << cel.inner_text.strip().to_ascii_iconv
        end
        player_data << cells
        #puts "player_data: #{player_data}"
        cells = []
      end
      #puts "player_data: #{player_data}"
      #puts "player_data.length: #{player_data.length}"
      player_data.pop
      player_data.pop
      player_data.pop
      player_data.reverse!
      player_data.pop
      player_data.reverse!
      player_data.pop
      player_data.pop
      player_data
    end
    
    def friendly_structure player_data
      # take player_data and turn it into array of Ostructs
      #puts "this is player data: #{player_data}"
      players = []
      player_data.each do |p|
        next unless (p.length > 0 && p[1] != "Pos")
        playa = OpenStruct.new
        # extract data from PGA cells:
        playa.start = p[0]
        playa.pos = p[1]
        playa.name = p[2]
        playa.fname = p[2].split(" ")[1].chomp(",") #need to improve this
        playa.lname = p[2].split(" ")[0].chomp(",") #need to improve this
        playa.thru = p[4]
        playa.to_par = p[5]
        playa.r1 = p[6] 
        playa.r2 = p[7]
        playa.r3 = p[8]
        playa.r4 = p[9]
        playa.total = (playa.r1.to_i + playa.r2.to_i + playa.r3.to_i + playa.r4.to_i).to_s
        #puts playa
        players << playa
      end
      
      return players
    end
  end
  
  
  class Nationwide
  end
  
end






