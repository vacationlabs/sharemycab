require 'sinatra'

class FormData
	attr_accessor :name,:email,:airport,:date,:time,:flight_no,:time_tolerance,:km_tolerance,:address,:lat,:long,:phone,:status, :error, :errors_found, :error_exists
	def initialize
		@airport_list = []
		@errors_found = []
		name,email,airport,date,time,flight_no,time_tolerance,km_tolerance,address,lat,long,phone,status = ""
		error_exists = false
	end

	def push_airport(airport_list)
		@airport_list = airport_list
	end

	def validate_empty
		field_names = ["name","email","airport","date","time","flight_no","time_tolerance","km_tolerance","address","lat","long","phone","status"]
		fields = [name,email,airport,date,time,flight_no,time_tolerance,km_tolerance,address,lat,long,phone,status]
		(0..fields.length-1).each do |i|
				if fields[i].length <= 0
					@errors_found.push({"msg"=>"Empty field",	"field"=>field_names[i]})
					@error_exists = true
				end
		end
	end

	def validate_email
		email_regex = /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/ 
		if not email_regex === email
			@error_exists = true
			@errors_found.push("msg"=>"Not Valid","field"=>"email")
		end
	end

	def validate_km_tolerance
		integer_regex = /[-+]?[0-9]+/
		if not (integer_regex === km_tolerance)
			@error_exists = true
			@errors_found.push("msg"=>"Not Valid","field"=>"km_tolerance")
		elsif not ((time_tolerance.to_i >= 0) and (time_tolerance.to_i <= 20))
			@error_exists = true
			@errors_found.push("msg"=>"Not in range 0 - 20","field"=>"km_tolerance")
		end
	end

	def validate_time_tolerance
		integer_regex = /[-+]?[0-9]+/
		puts time_tolerance
		if not (integer_regex === time_tolerance)
			@error_exists = true
			@errors_found.push("msg"=>"Not Valid","field"=>"time_tolerance")
		elsif not ((time_tolerance.to_i >= 0) and (time_tolerance.to_i <= 30))
			@error_exists = true
			@errors_found.push("msg"=>"Not in range 0 - 30","field"=>"time_tolerance")
		end
	end

	def validate_latitude
		float_regex = /[-+]?[0-9]*\.?[0-9]*/
		if not float_regex === @lat
			@error_exists = true
			@errors_found.push("msg"=>"Latitude Error","field"=>"lat")
		end
	end

	def validate_longitude
		float_regex = /[-+]?[0-9]*\.?[0-9]*/
		if not float_regex === @long
			@error_exists = true
			@errors_found.push("msg"=>"Longitude Error","field"=>"lat")
		end
	end

	def validate_phone
		phone_regex = /[-+]?[0-9\s()]+/
		if not phone_regex === @phone
			@error_exists = true
			@errors_found.push("msg"=>"Invalid Phone Number","field"=>"phone")
		end
	end 

	def validate_date_time
		hh,mm = time.split(':')
		year, month, day = date.split('-')
		if not ( is_integer(hh) and is_integer(mm) )
			@error_exists = true
			@errors_found.push("msg"=>"Invalid Time Value ","field"=>"time")
			if not (is_integer(year) and is_integer(month) and is_integer(day))
				@error_exists = true
				@errors_found.push("msg"=>"Invalid Date Value","field"=>"date")
			end
		end

		if year.to_i <= Time.now.year.to_i
			@error_exists = true
			@errors_found.push("msg"=>"Date is past","field"=>"date")
		elsif month.to_i <= Time.now.month.to_i
			@error_exists = true
			@errors_found.push("msg"=>"Date is past","field"=>"date")
		elsif day.to_i <= Time.now.day.to_i
			@error_exists = true
			@errors_found.push("msg"=>"Date is past","field"=>"date")
		elsif hh.to_i <= Time.now.hour.to_i
			@error_exists = true
			@errors_found.push("msg"=>"Time is past","field"=>"time")
		elsif mm.to_i <= Time.now.hour.to_i
			@error_exists = true
			@errors_found.push("msg"=>"Time is past","field"=>"time")
		end
	end
	def send_to_db
		#arrival_datetime = 
		data = [name,email,airport,arrival_datetime,flight,time_tolarance.to_i,km_tolarance.to_i,address,lat.to_f,long.to_f, phone,status]
	end
end


get '/' do
  erb :index
end

get '/form' do
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