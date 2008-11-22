#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# copy as much as you want to
# 10-29-2008
# purpose: scrape the official world golf ranking, and present it in a more usable form (Array of ostruct's)
# using Hpricot, open-uri

require 'rubygems'
require 'hpricot'
require 'nokogiri'
require 'open-uri'
require 'ostruct'

module CARL_SPACKLER
  VERSION = '0.1.0'

  class PGA
    def fetch(url, incl_missed_cut=false)
      doc = Nokogiri::HTML(open(url))
      
      player_data = []
      cells = []
            
      #made cut
      doc.css('table.altleaderboard').each do |table|
        #puts table
        #puts lb.inner_text
        if table.attributes['class'] == 'altleaderboard'
          table.css('tr').each do |row|
            row.css('td').each do |cel|
              # if it's a name, it's a hyperlink, so check for a
              innertext = cel.inner_text.strip()
              next unless innertext.length > 0
              #puts innertext
              cells << innertext
            end
            player_data << cells
            cells = []
          end
        end
      end
      
      if incl_missed_cut
        #missed cut
        doc.css('table.altleaderboard2').each do |lb|
          puts lb.inner_text
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
        playa.pos = p[0]
        playa.start = p[1]
        playa.name = p[2]
        playa.fname = p[2].split(" ")[0]
        playa.lname = p[2].split(" ")[1]
        playa.today = p[3]
        playa.thru = p[4]
        playa.to_par = p[5]
        playa.r1 = p[6]
        playa.r2 = p[7]
        playa.r3 = p[8]
        playa.r4 = p[9]
        playa.total = p[10]
        players << playa
      end
      
      players
    end
    
    
    
  end
  
end






