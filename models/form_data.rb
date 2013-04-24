require 'bigdecimal'

class FormData
	attr_accessor :name,:email,:airport,:date,:time,:flight_no,:time_tolerance,:km_tolerance,:address,:lat,:long,:phone,:status, :error, :errors_found, :error_exists

	def initialize(opts={})
		opts.each_pair do |k, v|
			if self.respond_to?("#{k}=")
				self.send("#{k}=", v)
			end
		end
		@airport_list = []
		@errors_found = []		
		error_exists = false
	end
	
	def push_airport(airport_list)
		@airport_list = airport_list
	end

	def validate_empty
		field_names = ["name","email","airport","date","time","time_tolerance","km_tolerance","address","phone"]
		fields = [name,email,airport,date,time,time_tolerance,km_tolerance,address,phone]
		(0..fields.length-1).each do |i|
				if (fields[i] || '').length == 0
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
		integer_regex = /[0-9]+/
		if not (integer_regex === km_tolerance)
			@error_exists = true
			@errors_found.push("msg"=>"Not Valid","field"=>"km_tolerance")
		elsif not ((km_tolerance.to_i >= 0) and (km_tolerance.to_i <= 10))
			@error_exists = true
			@errors_found.push("msg"=>"Not in range 0 - 10","field"=>"km_tolerance")
		end
	end

	def validate_time_tolerance
		integer_regex = /[0-9]+/
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
		if false and not float_regex === @lat
			@error_exists = true
			@errors_found.push("msg"=>"Latitude Error #{@lat}","field"=>"lat")
		end
	end

	def validate_longitude
		float_regex = /[-+]?[0-9]*\.?[0-9]*/
		if false and not float_regex === @long
			@error_exists = true
			@errors_found.push("msg"=>"Longitude Error #{@long}","field"=>"lat")
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
		now = Time.now
		adt = Time.parse("#{@date} #{@time} +0530")
		if(now + 2*60*60>adt)
			@error_exists = true
			@errors_found.push("msg" => "Arrival time should be at least two hours away", "field" => "time")
		end
	end

	def to_trip
		arrival_datetime = Time.parse("#{@date} #{@time} +0530")
		Trip.new(name, email, airport, arrival_datetime, flight_no, time_tolerance.to_i, km_tolerance.to_i, address, BigDecimal.new(lat), BigDecimal.new(long), phone)
	end
end

