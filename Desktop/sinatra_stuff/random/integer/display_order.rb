#!/usr/bin/ruby

require 'rest_client'
require 'sqlite3'

def display_order(run, sel)
	db = SQLite3::Database.open "rand_int.db"  #open Database
  if sel == 2
    sql = db.get_first_row "SELECT * FROM Random WHERE entry=#{run}"
    mini = sql[2]
    maxi = sql[3]
  end

  res = db.execute "SELECT result FROM Random WHERE entry=#{run}"
  rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
  ensure
    db.close if db

  len = res.length 
  tally = Array.new(len,0)  #create a new array of to keep track of how many times each number appears
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

  new_results = Array.new(len)

  tally_inc = 0  #indexes for arrays
  results_inc = 0

  new_results[results_inc] = results[0]

  #compares results table with tally table
  (0..(len-1)).each do |i|
    if new_results[results_inc] == results[i]  #check next value in results vs. previous stored value
      tally[tally_inc]+=1  #tally 1 for same value
    else
      tally_inc+=1  #increment tally_inc to go to next results value
      results_inc+=1
      new_results[results_inc] = results[i]  #save next number we are counting in the tally array
      tally[tally_inc]+=1  #tally 1 for new value
    end
  end

  num_unique = 0
  (0..(tally.length-1)).each do |i|
    if tally[i] > 0
      num_unique+=1
    end
  end
  print_len = num_unique-1

  if sel == 0
    #print results
    puts "Result Instances"
    (0..print_len).each do |i|
      if tally[i] == 0 || new_results[i] == 0
        break
      else
        puts "   #{new_results[i]}       #{tally[i]}"
      end
    end
  elsif sel == 1
    new_tally = Array.new(len)
    inst_results = Array.new(len)
    results_inc = 0  #indexes for arrays

    tally_max = tally.max
    while tally_max > 0
      (0..(len-1)).each do |i|
        if tally[i] == tally_max
          inst_results[results_inc] = new_results[i]  #save the number with the most appearances
          new_tally[results_inc] = tally[i]  #save instance number
          tally[i] = 0  #set to 0 so we do not repeat
          results_inc+=1  #increment index
        end
      end
      tally_max = tally.max  #check tally_max
    end

    #print results
    puts "Result Instances"
    (0..print_len).each do |i|
      if new_tally[i] == 0 || inst_results[i] == 0
        break
      else
        puts "   #{inst_results[i]}       #{new_tally[i]}"
      end
    end
  elsif sel == 2
    size = maxi-mini-print_len  #size of array
    if size == 0
      puts "All possible results were returned by the web server"
    else
      not_num = 0  #not included array index
      results_inc = 0
      not_inc = Array.new(size)  #not included array - saves numbers not included in results
      (mini..maxi).each do |i|
        if new_results[results_inc] == i  #if the number in the results list is in equal to the range, then don't print it
          results_inc+=1  #check the next result in the array
        else
          not_inc[not_num] = i  #add the number that isn't included in result list
          not_num+=1  #increase index
        end
      end
      puts "Possible results not returned by web server:"
      (0..(size-1)).each do |i|
        puts not_inc[i]
      end
    end
  end
  return
end