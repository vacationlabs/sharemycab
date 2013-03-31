require 'sinatra'
require './models/form_data.rb'

get '/' do
	@form = FormData.new
  puts @form.inspect
	erb :form
end

post '/submit' do
	@form = FormData.new
	@form.name = params[:name]
	@form.email = params[:email]
	@form.airport = params[:airport]
	@form.date = params[:date]
	@form.time = params[:time]
	@form.flight_no = params[:flight_no]
	@form.time_tolerance = params[:time_tolerance]
	@form.km_tolerance = params[:km_tolerance]
	@form.address = params[:address]
	@form.lat = params[:lat]
	@form.long = params[:long]
	@form.phone = params[:phone]
	@form.status = params[:status]

	@form.validate_empty
	@form.validate_email
	@form.validate_km_tolerance
	@form.validate_time_tolerance
	@form.validate_longitude
	@form.validate_latitude
	@form.validate_phone

	puts @form.time
	puts @form.date

	if @form.error_exists
		erb :form
	else
		erb :done
	end
end