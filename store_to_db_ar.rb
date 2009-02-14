#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# license: copy this code as much as you want to
# 01-16-2009
# purpose: using ActiveRecord to store information

require 'rubygems'
require 'active_record'

class Tournament < ActiveRecord::Base
  belongs_to :golfer
  belongs_to :event
end

class Event < ActiveRecord::Base
  belongs_to :tournament
  #has_one :event_names #??
end

class EventName < ActiveRecord::Base
  belongs_to :event
end

class Golfer < ActiveRecord::Base
  has_many :tournaments
  has_many :events#, :through => :tournaments
  TOURS = %w(all pga euro)

  #   # /*Anthony Kim  337 */
  def cuts_made(golfer_id, year, tour=TOURS[0])
    
    # works: 
    # Tournament.count(:all, :conditions => {:madecut => 1})
    # Tournament.count(:all, :conditions => {:madecut => -1})
    # Tournament.count(:all, :conditions => {:madecut => -1, :golfer_id => 337})
    
    # notes/ not working
    # Person.count(:conditions => "age > 26 AND job.salary > 60000", :include => :job)
    
    made = Tournament.count(:id, :include => [:events], :conditions => {:madecut => 1, :year => year, :golfer_id => golfer_id})
    
    Golfer.find(:all, :include => [:events], :conditions => {:id => 337})
    
    Tournament.count(:id, :include => [:events], :conditions => {:madecut => 1, :golfer_id => 337, events.year => 2008 })
    Tournament.count(:id, :include => [:event], :conditions => {:madecut => 1, :golfer_id => 337, event.year => 2008 })
    
    Tournament.count(:id, :include => [:event], :conditions => {:madecut => 1, :year => 2008, :golfer_id => 337})
    Tournament.count(:id, :include => [:event], :conditions => {:madecut => 1,:golfer_id => 337})
    made = Tournament.count(:id, :conditions => {:madecut => -1, :golfer_id => golfer_id})
    # :include => :events, 
    #   # /* cuts made */
    #   # select count(e.id) as cuts_made
    #   # FROM golfer_history gh
    #   # LEFT OUTER JOIN events e on gh.event_id = e.id
    #   # where golfer_id = 337 AND e.name IS NOT NULL
    #   # AND e.year = 2008 AND madecut IN(0,1)
  end
  
  def cuts_missed(golfer_id, year, tour=TOURS[0])
    #   # /* cuts missed */
    #   # select count(e.id) as cuts_missed
    #   # FROM golfer_history gh
    #   # LEFT OUTER JOIN events e on gh.event_id = e.id
    #   # where golfer_id = 337 AND e.name IS NOT NULL
    #   # AND madecut = -1 AND e.year = 2008
  end
  
  def top_tens(golfer_id, year, tour=TOURS[0])
  end
  
end

class Stats < ActiveRecord::Base
  
  def update_cuts_made_all_golfers
  end
  
  def update_cuts_missed_all_golfers
  end
  
  def update_top_tens_all_golfers
  end
  
  def update_all_stats
  end
  
end



# connect to the database (mysql in this case)
ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "127.0.0.1",
  :username => "root",
  :password => "",
  :database => "tour_data"
)

Golfer.find(:all, :include => :tournaments).each do |g|
  print "#{g.id}: #{g.fname} #{g.lname}"
  print " has played in tournament ids: "
  g.tournaments.each do |t|
    print "#{t.event_id}, "
  end
  
  puts ""
  
end
  
# puts "name: #{g.fname} #{g.lname}" 
# puts "#{g}"


# class Stats < ActiveRecord::Base
#   
#   def initialize db 
#     @db = db #ip, user, pass, name
#     @num_inserts = 0
#     
#     # connect to the database (mysql in this case)
#     ActiveRecord::Base.establish_connection(
#       :adapter  => "mysql",
#       :host     => @db.ip,
#       :username => @db.user,
#       :password => @db.pass,
#       :database => @db.name
#     )
#   end
#   
#   def all_golfers
#   end
#   
#   def post_total_cuts_made golfer_id
#   end
#   
#   def post_total_cuts_missed golfer_id
#   end
#   
#   def post_cuts_made_missed_all
#     # all golfers in database
#   end
#   
#   #attr_accessor 
#   

#   # 

# 
# end
# 
# 
# 
# 
# 
# 
