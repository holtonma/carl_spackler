
require 'carl_spackler'
require 'rubygems'
require 'open-uri'
require 'nokogiri'

include CARL_SPACKLER
  euro = Euro.new
  #tourney = euro.tourney_info(euro.get_urls(2008)[0])
  url = euro.get_urls(2008)[0]
  puts url
  doc = Nokogiri::HTML(open(url))
  #puts "#{doc.css()}"
  #puts "tournHeaderDiv: #{doc.css('#scoresBoard2').first.inner_text}"
  #scoresBoard2
  #made cut
  #puts doc.css('div#scoresBoard2 table')
  
  doc.css('div#scoresBoard2 table').each do |table|
    table.css('tr').each do |row|
      #puts "row: #{row.inner_text}"
      row.css('td').each do |cel|
        puts "cel: #{cel.inner_text}"
      end
    end
  end
      

  