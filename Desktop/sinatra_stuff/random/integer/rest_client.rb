#!/usr/bin/ruby

require 'rest_client'
require 'sqlite3'
require_relative 'display_order'

#call the server count times between small and large ranges
def call_random_server(small, large, count, run_num)
	db = SQLite3::Database.open "rand_int.db"
  #call the server and give min and max variables
	#call generator (web server)
	(0..(count-1)).each do |i|    #iterate count # of times
    #t2 = Time.now  #end timer 2  
    #response.to_str = the html results on page
    response = RestClient.get 'localhost:4567/random/integer', {:params => {:min =>small, :max => large}} 
    #prepare statement is faster than running query every time
    sql = db.prepare("INSERT INTO Random(entry, min, max, result) VALUES(#{run_num}, #{small}, #{large}, #{response.to_str} )")
    #insert into sql table
    sql.execute
    #output the results to terminal
    puts "response #{i+1}: #{response.to_str}"
	end

    #close db connection
	rescue SQLite3::Exception => e
		puts "Exception occured"
		puts e

	ensure
    sql.close if sql
		db.close if db
	return
end

#finds the next entry number to write to
def current_entry()
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
    prev_entry = Integer(prev_entry[2..-3])  #ignore the brackets in beginning and end (2 on both sides) & quotes
    curr_entry = (prev_entry + 1)  #when there has been an entry, make the next entry = prev_entry + 1
  end

  rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
  ensure
    db.close if db

  return curr_entry
end

#prompt before calling the random generator function
def random_num_gen()
  #puts 'This is a random number generator. The user will input the minimum 
  #and maximum integers to declare the range the generator can output. The user 
  #will also input the amount of times the generator will be called. The final
  #results will be stored in a table, which will be displayed after last call 
  #to the generator is given.'
  entry = current_entry  #set the entry number using 
  puts 'Enter minimum value for range:'
  min_int = gets.chomp
  min_num = min_int.to_i
  puts 'Enter maximum value for range:'
  max_int = gets.chomp
  max_num = max_int.to_i
  #ensure that the minimum number is less than the maximum number
  while max_num <= min_num
    puts 'Max number is smaller than minimum number. Enter maximum value for range:'
    max_int = gets.chomp
    max_num = max_int.to_i
  end
  puts 'Enter the number of random numbers you would like to be output:'
  count = gets.chomp
  count = count.to_i
  puts ""
  t1 = Time.now
  call_random_server(min_int, max_int, count, entry)
  t2 = Time.now
  puts t2-t1
  return
end

#shows different run entries of data, min, max values, and count
def show_entries()
  current_run = current_entry - 1
  puts "Which run of data would you like to view? (1 - #{current_run})"
  run_view = gets.chomp  #get the run that the user would like to view
  running = 1

  while running == 1
    puts ""
    puts "Enter help to see commands, or type in command:"
    comm = gets.chomp

    case comm
    when "minmax"  #show minimum and maximum
      puts minmax(run_view)
    when "count"  #show the number of times user called web service
      puts ret_count(run_view)
    when "results"  #show results ordered
      display_results(run_view)
    when "noret"  #show what was not shown in results table
      display_order(run_view,2)
    when "help"
      show_help
    when "exit"
      running = 0
    else
      puts "That was not a valid command."
    end
  end

  return
end

#returns min and max values from a certain web server run
def minmax(run)
  db = SQLite3::Database.open "rand_int.db"  #open Database
  results = db.get_first_row "SELECT * FROM Random WHERE entry=#{run}"  #get only first row of result set
  rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
  ensure
    db.close if db

  return "Min: #{results[2]}, Max: #{results[3]}"
end

#returns the number of requests to the server occured during a certain run
def ret_count(run)
  db = SQLite3::Database.open "rand_int.db"  #open Database
  number = db.execute "SELECT count(*) FROM Random WHERE entry=#{run}"  #count the number of results 
  number = String(number)  #convert to string to separate brackets
  number = number[2..-3]
  rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
  ensure
    db.close if db
  return "The total count is #{number}"
end

#returns results in an ordered list by user choice
def display_results(run)
  db = SQLite3::Database.open "rand_int.db"  #open Database
  running = 1
  while running == 1  #allow user to view both without exiting current menu
    puts ""
    puts "Would you like to view the results in order by: (type help for list of commands)"
    order = gets.chomp

    case order
    when "value"
      display_order(run,0)
    when "inst"
      display_order(run,1)
    when "help"
      display_help
    when "exit"
      running = 0
    else
      puts "That was not a valid command."
    end
  end

  rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
  ensure
    db.close if db
  return
end

def show_help()
  puts "Commands for viewing data from run"
  puts ""
  puts "minmax - Displays minimum and maximum values of the range sent to the web service in the run."
  puts ""
  puts "count - Displays the number of times the web service was called in the run."
  puts ""
  puts "results - Displays new menu to display ordered results."
  puts ""
  puts "noret - Displays the numbers not returned from service that were in min/max range."
  puts ""
  puts "exit - Returns to previous menu, or to chose another run."
  return
end

def display_help()
  puts "value - Value(smallest to largest) or"
  puts "inst - Number of instances the number is generated(most to least)."
  puts "exit - exit to previous menu."
end

begin
  running = 1
  while running == 1
    puts ""
    puts "Commands:"
    puts "rangen - Calls the random number generator a user defined amount of times."
    puts "show - Goes to menu to show data from previous server runs."
    puts "exit - Closes the user menu"
    comm = gets.chomp

    case comm
    when "rangen"
      random_num_gen
    when "show"
      show_entries
    when "exit"
      running = 0
      puts "Goodbye"
    else
      puts "That was not a valid command."
    end
  end
end