#!/usr/bin/ruby
require 'rubygems'
require 'tlsmail'
require 'mail'    

# matched_trips = trips.select {|t| trip_matches?(t, current_trip)}

def send_match_notifications(current_trip, matched_trips)
  if !matched_trips.empty?
    response_email = "Hello,\n #{current_trip.name} \n\n \t You are travelling to same destination as :\n"

    matched_trips.each do |trip|
      response_email+= "\t\tName :#{trip.name} \n\t\t Email Id  :#{trip.email}\n\t\t Phone Number: #{trip.phone}\n"
    end

    response_email+="\n\nYou can contact any of the people above to share a cab.\n\n\nPleased to serve you!,\n-ShareMyCab"


    mail = Mail.new do
      from 'shan2chat@gmail.com'
      to current_trip.email
      subject "Cab Sharing"
      body response_email
    end
       
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', 'shan2chat@gmail.com', 'q3erty54321', :login) do |smtp|
      smtp.send_message(mail.to_s, 'shan2chat@gmail.com', current_trip.email)
    end
 end   
end