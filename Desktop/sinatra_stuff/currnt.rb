#!/usr/bin/ruby

require 'rest_client'
require 'sqlite3'
 begin
  db = SQLite3::Database.open "rand_int.db"
  num_rows = db.execute "SELECT COUNT(*) as count FROM Random"  #get the number of rows in table
  num_rows=String(num_rows)
  #len = num_rows.length
  num_rows = Integer(num_rows[2..-3])

  prev_entry = db.execute "SELECT entry FROM Random WHERE Id = #{num_rows}"
  if !prev_entry.any?  #check if the table Random is empty
    curr_entry = 1  #if there are no entries make the next entry = 1
  else
    prev_entry = String(prev_entry)  #make prev entry into string to change into integer
    prev_entry = Integer(prev_entry[3..-4])  #ignore the brackets in beginning and end (2 on both sides)
    curr_entry = (prev_entry + 1)  #when there has been an entry, make the next entry = prev_entry + 1
  end

  rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
  ensure
    db.close if db
  puts curr_entry

end