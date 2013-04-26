require 'rubygems'
require 'pg'
require 'time'

set :db_host, ENV['DB_HOST'] || "localhost"
set :db_name, ENV['DB_NAME'] || "sharemycab"
set :db_user, ENV['DB_USER'] || "sharemycab"
set :db_password, ENV['DB_PASSWORD'] || "sharemycab"

class Trip
	attr_accessor :id,:name,:email,:airport,:arrival_datetime,:flight_no,:time_tolerance,:km_tolerance,:address,:lat,:long,:phone,:status

	def initialize(name,email,airport,arrival_datetime,flight_no,time_tolerance,km_tolerance,address,lat,long,phone,status = "active")
		@name = name
		@email = email
		@airport = airport
		@arrival_datetime = arrival_datetime
		@flight_no = flight_no
		@time_tolerance = time_tolerance
		@km_tolerance = km_tolerance
		@address = address
		@lat = lat	
		@long = long	
		@phone = phone
		@status = status
		@application = Sinatra::Application
	end

	def save
		conn = PG::Connection.open(:host => @application.settings.db_host,:dbname => @application.settings.db_name, :user => @application.settings.db_user, :password => @application.settings.db_password)
		adt = @arrival_datetime.getutc.strftime('%F %T')
		# @arrival_datetime = arrival_datetime.utc
		# TODO -- Prevent SQL Injection
		res = conn.exec("Insert into Trip (name,email,airport,arrival_datetime,flight_no,time_tolerance,km_tolerance,address,lat,long,phonenumber,status) values('#{@name}','#{@email}','#{@airport}','#{adt}','#{@flight_no}',#{@time_tolerance},#{@km_tolerance},'#{@address}',#{@lat},#{@long},'#{@phone}','#{@status}');")
	end

	def self.fetch(id)
		conn = PG::Connection.open(:host => @application.settings.db_host,:dbname => @application.settings.db_name, :user => @application.settings.db_user, :password => @application.settings.db_password)
		sql = "Select name,email,airport,arrival_datetime,flight_no,time_tolerance,km_tolerance,address,lat,long,phonenumber,status from Trip where id = #{id}"
		res = conn.exec(sql)

		#puts "MAX VALUE FROM DB=======================================================#{res.inspect}"
		b = res.values[0]
		time = Time.parse(b[3] + "UTC").getlocal("+05:30")
		return Trip.new(b[0],b[1],b[2],time,b[4],b[5],b[6],b[7],b[8],b[9],b[10],b[11])
	end

	def match_trips
		conn = PG::Connection.open(:host => @application.settings.db_host,:dbname => @application.settings.db_name, :user => @application.settings.db_user, :password => @application.settings.db_password)
		usertime = Time.new
		usertime = @arrival_datetime.getutc.strftime("%F %T")  
		sql = "Select name,email,airport,arrival_datetime,flight_no,time_tolerance,km_tolerance,address,lat,long,phonenumber,status from Trip where airport = '#{@airport}' and abs(extract(epoch from (timestamp '#{usertime}' - arrival_datetime))) < (#{@time_tolerance}*60)"
		res = conn.exec(sql)
		
		tripobjects = []
		a = res.values
		time = Time.new

		res.values.each do |b|
			time = Time.parse(b[3] + "UTC").getlocal("+05:30")
			tripobjects.push(Trip.new(b[0],b[1],b[2],time,b[4],b[5].to_i,b[6].to_i,b[7],BigDecimal.new(b[8]), BigDecimal.new(b[9]), b[10],b[11]))
		end

		return tripobjects
	end

	def self.check_airport(user1, user2)
	  return user1.airport==user2.airport
	end

	def self.dist_tolerance_check(t1, t2)
	  diff = location_dist_difference(t1.lat, t1.long, t2.lat, t2.long)
	  return (diff <= t1.km_tolerance && diff <= t2.km_tolerance)
	end


	def self.time_tolerance_check(user1, user2)
	  (early, late) = (user1.arrival_datetime < user2.arrival_datetime) ? [user1, user2] : [user2, user1]
	  return (early.arrival_datetime + (early.time_tolerance*60)) > late.arrival_datetime
	end

	def self.trip_uniqueness(t1,t2)
		return (t1.email!=t2.email)
	end

	def self.trip_matches?(t1, t2)
	  return (check_airport(t1, t2) && dist_tolerance_check(t1, t2) && time_tolerance_check(t1, t2) && trip_uniqueness(t1,t2))
	end
end
