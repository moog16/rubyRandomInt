#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

get '/random/integer' do
	#minimum = params[:min].to_i
	#maximum = params[:max].to_i
	#random_number = 1+maximum-minimum
	minimum = Integer(params[:min])
	maximum = Integer(params[:max])
	random_number = 1+maximum-minimum
	#(params[:max].to_i + rand(1+params[:max].to_i-params[:min].to_i)).to_s
	(minimum + rand(random_number)).to_s()
end