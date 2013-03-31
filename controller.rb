require 'sinatra'
require './models/form_data.rb'
require './lib/distance.rb'
require './models/trip.rb'

AIRPORTS = {
	'GOI' => 'Goa, Dabolim Airport',
	'DEL' => 'Delhi, Indira Gandhi International Airport'
}

get '/' do
	@form = FormData.new
  puts @form.inspect
	erb :landing
end

post '/submit' do
	@form = FormData.new({
		'name' => params[:name],
		'email' => params[:email],
		'airport' => params[:airport],
		'date' => params[:date],
		'time' => params[:time],
		'flight_no' => params[:flight_no],
		'km_tolerance' => params[:km_tolerance],
		'time_tolerance' => params[:time_tolerance],
		'address' => params[:address],
		'lat' => params[:lat],
		'long' => params[:long],
		'phone' => params[:phone]
	})
	@form.validate_empty
	@form.validate_email
	@form.validate_km_tolerance
	@form.validate_time_tolerance
	@form.validate_longitude
	@form.validate_latitude
	@form.validate_phone
	@form.validate_date_time

	if @form.error_exists
		erb :landing
	else
		trip = @form.to_trip
		trip.save
		erb :done
	end
end