#!/usr/bin/ruby

require 'rubygems'
require 'sqlite3'

begin
    
    db = SQLite3::Database.open "rand_int.db"
    
    stm = db.prepare "SELECT * FROM Random" 
    rs = stm.execute 
    
    rs.each do |row|
        puts row.join "\s"
    end
           
rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
ensure
    stm.close if stm
    db.close if db
end