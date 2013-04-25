#!/usr/bin/ruby

require 'rest_client'
require 'sqlite3'

def show_results_ext(run)
  db = SQLite3::Database.open "rand_int.db"  #open Database
  res = db.execute "SELECT result FROM Random WHERE entry=#{run}"
  rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
  ensure
    db.close if db
  len = res.length  #want an array twice the size of the results => worst case
  tally = Array.new(2*len,0)  #create a new array of to keep track of how many times each number appears
  res = res.sort  #sort the array first
  
  #sql reads in an array, cannot convert to array of integers
  string_res = String(res)  #must convert array to string
  string_res_len = string_res.length-1
  temp_len = 0  #create temp_len var to take away brackets and commas
  res_count = 0  #the index for the results array 

  #since last number does not have a comma, must place comma
  string_res[string_res_len] = ","
  results = Array.new(len)  #results array to store new numbers

  #need to write function here in order to compensate for different digit lengths
  (0..string_res_len).each do |i|
    if string_res[i] == ","  #check for comma, which signifies the end of a number
      #convert string_res into an int. Then store in results
      results[res_count] = Integer( string_res[ ( i-temp_len+2 )..( i-2 ) ] ) 
      temp_len = 0  #reset temp_len
      res_count+=1  #increment to next element in array
    else
      temp_len+=1  #increment temp_len to next char in string
    end
  end

  #tally[evens] == the number we are keeping track of
  #tally[odds] == the number of times a number in the results list appears
  tally_inc = 1  #what keeps track of the tally marks for a certain result
  num_inc = 0
  tally[0] = results[0]  #place the first value in array[0]

  #compares results table with tally table
  (0..(len-1)).each do |i|
    if tally[num_inc] == results[i]  #check next value in results vs. previous stored value
      tally[tally_inc]+=1  #tally 1 for same value
    else
      tally_inc+=2  #increment tally_inc to go to next results value
      num_inc+=2
      tally[num_inc] = results[i]  #save next number we are counting in the tally array
      tally[tally_inc]+=1  #tally 1 for new value
    end
  end

  #print results
  puts "Result Instances"
  (0..(tally.length-1)/2).each do |i|
    if tally[2*i] == 0 
      break
    else
      puts "   #{tally[2*i]}       #{tally[(2*i)+1]}"
    end
  end
  return
   
end


