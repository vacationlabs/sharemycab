require 'rubygems'
require 'pg'
require 'time'
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
	end

	def save
		conn = PG::Connection.open(:host => "localhost",:dbname => 'sharecab_db', :user => "sharecab", :password => "sharecab")
		
		@arrival_datetime = arrival_datetime.utc
		@arrival_datetime = @arrival_datetime.strftime("%F %T")
		res = conn.exec("Insert into Trip (name,email,airport,arrival_datetime,flight_no,time_tolerance,km_tolerance,address,lat,long,phonenumber,status) values('#{@name}','#{@email}','#{@airport}','#{@arrival_datetime}','#{@flight_no}',#{@time_tolerance},#{@km_tolerance},'#{@address}',#{@lat},#{@long},'#{@phone}','#{@status}');")
		puts res
	end

	def self.fetch(id)
		conn = PG::Connection.open(:host => "localhost",:dbname => 'sharecab_db', :user => "sharecab", :password => "sharecab")
		sql = "Select name,email,airport,arrival_datetime,flight_no,time_tolerance,km_tolerance,address,lat,long,phonenumber,status from Trip where id = #{id}"
		res = conn.exec(sql)
		a = res.values
		b = a[0]

		time = Time.new
		timestring = b[3] + "UTC"
		puts timestring
		time = Time.parse(timestring)
		time = time.getlocal
		t1 = Trip.new(b[0],b[1],b[2],time,b[4],b[5],b[6],b[7],b[8],b[9],b[10],b[11])
		return t1
	end

	def match_trips()
		conn = PG::Connection.open(:host => "localhost",:dbname => 'sharecab_db', :user => "sharecab", :password => "sharecab")
		usertime = Time.new
		@arrival_datetime = arrival_datetime.utc
		usertime = @arrival_datetime.strftime("%F %T")  
		sql = "Select name,email,airport,arrival_datetime,flight_no,time_tolerance,km_tolerance,address,lat,long,phonenumber,status from Trip where airport = '#{@airport}' and abs(extract(epoch from (timestamp '#{usertime}' - arrival_datetime))) < (#{@time_tolerance}*60)"
		res = conn.exec(sql)
		tripobjects = []
		a = res.values
		time = Time.new

		(0...a.length).each do |k|
			b = a[k]
			timestring = b[3] + "UTC"
			time = Time.parse(timestring)
			time = time.getlocal
			t1 = Trip.new(b[0],b[1],b[2],time,b[4],b[5],b[6],b[7],b[8],b[9],b[10],b[11])
			tripobjects.push(t1)
		end
		return tripobjects
	end

	def validate
	end
end
# time = Time.now
# t = Trip.new("a","b","c",time,"e",10,20,"i",104.2222222,178.1111111,"9158002020")
# t.save
t1 = Trip.fetch(2)
b = []
b = t1.match_trips
b.each do |k|
	puts k.inspect
	puts "\n---------------------------------------------------------------------\n"
end