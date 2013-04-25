#!/usr/bin/ruby
require 'rubygems'
require 'tlsmail'
require 'mail'    

# matched_trips = trips.select {|t| trip_matches?(t, current_trip)}

def send_match_notifications(current_trip, matched_trips)
  if !matched_trips.empty?
    response_email = "Hello #{current_trip.name},\n\nGreetings from shareMyCab! Here are some other people travelling to destinations around you on #{trip.arrival_datetime.date}:\n"

    puts "Matched trips=====================#{matched_trips}"

    matched_trips.each do |trip|
      response_email+= "\t\tName :#{trip.name} \n\t\tEmail Id :#{trip.email}\n\t\tPhone Number: #{trip.phone}\n"
    end

    response_email+="\n\nYou can contact any of the people above to share a cab.\n\n\nPleased to serve you!,\n-ShareMyCab"


    mail = Mail.new do
      from 'services@vacationlabs.com'
      to current_trip.email
      subject "shareMyCab - You Have People Travelling To Destinations Near You"
      body response_email
    end
       
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', 'services@vacationlabs.com', :login) do |smtp|
      smtp.send_message(mail.to_s, 'services@vacationlabs.com', current_trip.email)
    end
 end   
end