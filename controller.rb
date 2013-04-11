require "rubygems"
require "net/http"
require 'sinatra'
require './models/form_data.rb'
require './lib/distance.rb'
require './models/trip.rb'
require './lib/send_mail.rb'
require "json"

POPULAR_AIRPORTS = {
	'BOM'=>'Bombay (Mumbai),Chhatrapati Shivaji Airport (BOM)',
	'BLR'=>'Bangalore,Hindustan Airport (BLR)',
	'CCU'=>'Calcutta (Kolkata),Netaji Subhas Chandra Airport (CCU)',
	'DEL'=>'Delhi,Indira Gandhi International Airport (DEL)',
	'GOI'=>'Goa,Dabolim Airport (GOI)',
	'HYD'=>'Hyderabad,Begumpet Airport (HYD)',
	'MAA'=>'Madras (Chennai),Chennai Airport (MAA)'
}

AIRPORTS = {
	'IXA'=>'Agartala,Singerbhil Airport (IXA)',
	'AGX'=>'Agatti Island,Agatti Island Airport (AGX)',
	'AGR'=>'Agra,Kheria Airport (AGR)',
	'AMD'=>'Ahmedabad,Ahmedabad Airport (AMD)',
	'AJL'=>'Aizawl,Aizawl Airport (AJL)',
	'AKD'=>'Akola,Akola Airport (AKD)',
	'IXD'=>'Allahabad,Bamrauli Airport (IXD)',
	'IXV'=>'Along,Along Airport (IXV)',
	'ATQ'=>'Amritsar,Raja Sansi Airport (ATQ)',
	'IXU'=>'Aurangabad,Chikkalthana Airport (IXU)',
	'IXB'=>'Bagdogra,Bagdogra Airport (IXB)',
	'RGH'=>'Balurghat,Balurghat Airport (RGH)',
	'BLR'=>'Bangalore,Hindustan Airport (BLR)',
	'BEK'=>'Bareli,Bareli Airport (BEK)',
	'IXG'=>'Belgaum,Sambre Airport (IXG)',
	'BEP'=>'Bellary,Bellary Airport (BEP)',
	'BUP'=>'Bhatinda,Bhatinda Airport (BUP)',
	'BHU'=>'Bhavnagar,Bhavnagar Airport (BHU)',
	'BHO'=>'Bhopal,Bhopal Airport (BHO)',
	'BBI'=>'Bhubaneswar,Bhubaneswar Airport (BBI)',
	'BHJ'=>'Bhuj,Rudra Mata Airport (BHJ)',
	'BKB'=>'Bikaner,Bikaner Airport (BKB)',
	'PAB'=>'Bilaspur,Bilaspur Airport (PAB)',
	'BOM'=>'Bombay (Mumbai),Chhatrapati Shivaji Airport (BOM)',
	'CCU'=>'Calcutta (Kolkata),Netaji Subhas Chandra Airport (CCU)',
	'CBD'=>'Car Nicobar,Car Nicobar Airport (CBD)',
	'IXC'=>'Chandigarh,Chandigarh Airport (IXC)',
	'CJB'=>'Coimbatore,Peelamedu Airport (CJB)',
	'COH'=>'Cooch Behar,Cooch Behar Airport (COH)',
	'CDP'=>'Cuddapah,Cuddapah Airport (CDP)',
	'NMB'=>'Daman,Daman Airport (NMB)',
	'DAE'=>'Daparizo,Daparizo Airport (DAE)',
	'DAI'=>'Darjeeling,Darjeeling Airport (DAI)',
	'DED'=>'Dehra Dun,Dehra Dun Airport (DED)',
	'DEL'=>'Delhi,Indira Gandhi International Airport (DEL)',
	'DEP'=>'Deparizo,Deparizo Airport (DEP)',
	'DBD'=>'Dhanbad,Dhanbad Airport (DBD)',
	'DHM'=>'Dharamsala,Gaggal Airport (DHM)',
	'DIB'=>'Dibrugarh,Chabua Airport (DIB)',
	'DMU'=>'Dimapur,Dimapur Airport (DMU)',
	'DIU'=>'Diu,Diu Airport (DIU)',
	'GAY'=>'Gaya,Gaya Airport (GAY)',
	'GOI'=>'Goa,Dabolim Airport (GOI)',
	'GOP'=>'Gorakhpur,Gorakhpur Airport (GOP)',
	'GUX'=>'Guna,Guna Airport (GUX)',
	'GAU'=>'Guwahati,Borjhar Airport (GAU)',
	'GWL'=>'Gwalior,Gwalior Airport (GWL)',
	'HSS'=>'Hissar,Hissar Airport (HSS)',
	'HBX'=>'Hubli,Hubli Airport (HBX)',
	'HYD'=>'Hyderabad,Begumpet Airport (HYD)',
	'IMF'=>'Imphal,Municipal Airport (IMF)',
	'IDR'=>'Indore,Indore Airport (IDR)',
	'JLR'=>'Jabalpur,Jabalpur Airport (JLR)',
	'JGB'=>'Jagdalpur,Jagdalpur Airport (JGB)',
	'JAI'=>'Jaipur,Sanganeer Airport (JAI)',
	'JSA'=>'Jaisalmer,Jaisalmer Airport (JSA)',
	'IXJ'=>'Jammu,Satwari Airport (IXJ)',
	'JGA'=>'Jamnagar,Govardhanpur Airport (JGA)',
	'IXW'=>'Jamshedpur,Sonari Airport (IXW)',
	'PYB'=>'Jeypore,Jeypore Airport (PYB)',
	'JDH'=>'Jodhpur,Jodhpur Airport (JDH)',
	'JRH'=>'Jorhat,Rowriah Airport (JRH)',
	'IXH'=>'Kailashahar,Kailashahar Airport (IXH)',
	'IXQ'=>'Kamalpur,Kamalpur Airport (IXQ)',
	'IXY'=>'Kandla,Kandla Airport (IXY)',
	'KNU'=>'Kanpur,Kanpur Airport (KNU)',
	'IXK'=>'Keshod,Keshod Airport (IXK)',
	'HJR'=>'Khajuraho,Khajuraho Airport (HJR)',
	'IXN'=>'Khowai,Khowai Airport (IXN)',
	'COK'=>'Kochi,Kochi Airport (COK)',
	'KLH'=>'Kolhapur,Kolhapur Airport (KLH)',
	'KTU'=>'Kota,Kota Airport (KTU)',
	'CCJ'=>'Kozhikode,Calicut International Airport (CCJ)',
	'KUU'=>'Kulu,Bhuntar Airport (KUU)',
	'IXL'=>'Leh,Leh Airport (IXL)',
	'IXI'=>'Lilabari,Lilabari Airport (IXI)',
	'LKO'=>'Lucknow,Amausi Airport (LKO)',
	'LUH'=>'Ludhiana,Ludhiana Airport (LUH)',
	'MAA'=>'Madras (Chennai),Chennai Airport (MAA)',
	'IXM'=>'Madurai,Madurai Airport (IXM)',
	'LDA'=>'Malda,Malda Airport (LDA)',
	'IXE'=>'Mangalore,Bajpe Airport (IXE)',
	'MOH'=>'Mohanbari,Mohanbari Airport (MOH)',
	'MZA'=>'Muzaffarnagar,Muzaffarnagar Airport (MZA)',
	'MZU'=>'Muzaffarpur,Muzaffarpur Airport (MZU)',
	'MYQ'=>'Mysore,Mysore Airport (MYQ)',
	'NAG'=>'Nagpur,Sonegaon Airport (NAG)',
	'NDC'=>'Nanded,Nanded Airport (NDC)',
	'ISK'=>'Nasik,Gandhinagar Airport (ISK)',
	'NVY'=>'Neyveli,Neyveli Airport (NVY)',
	'OMN'=>'Osmanabad,Osmanabad Airport (OMN)',
	'PGH'=>'Pantnagar,Pantnagar Airport (PGH)',
	'IXT'=>'Pasighat,Pasighat Airport (IXT)',
	'IXP'=>'Pathankot,Pathankot Airport (IXP)',
	'PAT'=>'Patna,Patna Airport (PAT)',
	'PNY'=>'Pondicherry,Pondicherry Airport (PNY)',
	'PBD'=>'Porbandar,Porbandar Airport (PBD)',
	'IXZ'=>'Port Blair,Port Blair Airport (IXZ)',
	'PNQ'=>'Pune,Lohegaon Airport (PNQ)',
	'PUT'=>'Puttaparthi,Puttaprathe Airport (PUT)',
	'RPR'=>'Raipur,Raipur Airport (RPR)',
	'RJA'=>'Rajahmundry,Rajahmundry Airport (RJA)',
	'RAJ'=>'Rajkot,Civil Airport (RAJ)',
	'RJI'=>'Rajouri,Rajouri Airport (RJI)',
	'RMD'=>'Ramagundam,Ramagundam Airport (RMD)',
	'IXR'=>'Ranchi,Ranchi Airport (IXR)',
	'RTC'=>'Ratnagiri,Ratnagiri Airport (RTC)',
	'REW'=>'Rewa,Rewa Airport (REW)',
	'RRK'=>'Rourkela,Rourkela Airport (RRK)',
	'RUP'=>'Rupsi,Rupsi Airport (RUP)',
	'SXV'=>'Salem,Salem Airport (SXV)',
	'TNI'=>'Satna,Satna Airport (TNI)',
	'SHL'=>'Shillong,Shillong Airport (SHL)',
	'SSE'=>'Sholapur,Sholapur Airport (SSE)',
	'IXS'=>'Silchar,Kumbhirgram Airport (IXS)',
	'SLV'=>'Simla,Simla Airport (SLV)',
	'SXR'=>'Srinagar,Srinagar Airport (SXR)',
	'STV'=>'Surat,Surat Airport (STV)',
	'TEZ'=>'Tezpur,Salonibari Airport (TEZ)',
	'TEI'=>'Tezu,Tezu Airport (TEI)',
	'TJV'=>'Thanjavur,Thanjavur Airport (TJV)',
	'TRV'=>'Thiruvananthapuram,Thiruvananthapuram International Airport (TRV)',
	'TRZ'=>'Tiruchirapally,Civil Airport (TRZ)',
	'TIR'=>'Tirupati,Tirupati Airport (TIR)',
	'TCR'=>'Tuticorin,Tuticorin Airport (TCR)',
	'UDR'=>'Udaipur,Dabok Airport (UDR)',
	'BDQ'=>'Vadodara,Vadodara Airport (BDQ)',
	'VNS'=>'Varanasi,Varanasi Airport (VNS)',
	'VGA'=>'Vijayawada,Vijayawada Airport (VGA)',
	'VTZ'=>'Visakhapatnam,Visakhapatnam Airport (VTZ)',
	'WGC'=>'Warangal,Warangal Airport (WGC)'
}

get '/' do
	@form = FormData.new
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
	@form.validate_phone
	@form.validate_date_time

	return (erb :landing) if @form.error_exists

	puts "======================= BEFORE CALLING API"

	(lat, long) = get_lat_long_from_google_object_key(params[:destination_ref_key])
	@form.lat = lat
	@form.long = long
	@form.validate_longitude
	@form.validate_latitude

	puts "======================= AFTER CALLING API #{@form.error_exists}"

	return (erb :landing) if @form.error_exists


	puts "======================= BEFORE SABING"
	trip = @form.to_trip
	trip.save

	##select * from trip where id= (select  max(id) from trip);






	possible_matches = trip.match_trips
	puts "POSSIBLE MATCHES ====================== #{possible_matches.inspect}"



	actual_matches = possible_matches.select {|t| Trip.trip_matches?(trip, t) }
	if actual_matches.length>0
		puts "======================== #{actual_matches.inspect}"
		send_match_notifications(trip, actual_matches)
	end
	erb :done
end


get '/places/:address' do
	keyword=URI.escape(params[:address])
	uri = URI("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{keyword}&types=establishment&sensor=false&key=AIzaSyAGeap2PXa_AS19npQLjDlUbE8w0t_atwE")

	result = nil

	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
	  request = Net::HTTP::Get.new uri.request_uri
	  response = http.request request # Net::HTTPResponse object
		result = JSON.parse(response.body)
	end

	predictions=[]
	descriptions = result["predictions"]
	descriptions.each do |description|
		predictions.push({ 'address' => description["description"], 'reference_key' => description["reference"]})
	end

	content_type :json
  { :address_prediction => predictions }.to_json
end



def get_lat_long_from_google_object_key(key)
	keyword=URI.escape(key)
	uri = URI("https://maps.googleapis.com/maps/api/place/details/json?reference=#{keyword}&sensor=false&key=AIzaSyAGeap2PXa_AS19npQLjDlUbE8w0t_atwE")
	lat, long = [nil, nil]
	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
	  request = Net::HTTP::Get.new uri.request_uri
	  response = JSON.parse(http.request(request).body)
		lat =response["result"]["geometry"]["location"]["lat"]
		long = response["result"]["geometry"]["location"]["lng"]
	end
	return [lat.to_s, long.to_s]
end
