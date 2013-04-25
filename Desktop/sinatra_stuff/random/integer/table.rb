#!/usr/bin/ruby

require 'sqlite3'

begin
	db = SQLite3::Database.new("rand_int.db")

	db.execute "CREATE TABLE IF NOT EXISTS Random(Id INTEGER PRIMARY KEY AUTOINCREMENT, entry INTEGER, min INTEGER, max INTEGER, result INTEGER)"
	
rescue SQLite3::Exception => e
	puts "Exception occrued"
	puts e
ensure
	db.close if db
end
