#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'hpricot'
require 'icalendar'
require 'date'

include Icalendar

def dump_day(items, year, month, cal)
    raise "Not an array!" unless items.is_a?(Array)
    raise "Not a calendar!" unless cal.is_a?(Calendar)

#    puts "-----"
#    puts "Date -> #{items[0]}"
    date = items[0].split(" ")[2]
    for i in (1..items.size)
        shr = nil
        min = nil
        hr  = nil

        #puts "Subject -> #{items[i].split("\n").first}" unless items[i] == nil
        if not items[i] == nil 
            items[i].split("\n").each do |line|
                if line.include?("p.m.") || line.include?("a.m.")
                    time = line.split(",").first
                    if time.include?("-")
                        times = time.split("-")
                        stime = times[0]
                        etime = times[1]
#                        puts "Time -> #{stime} - #{etime}"
                    else
                        times = time.split(":")
                        shr  = times[0].to_i
                        min = times[1].split(" ").first
                        hr = shr + 1
                        if time.include?("p.m.") && hr < 12
                            hr += 12
                        end
                        if time.include?("p.m.") && shr < 12
                            shr += 12
                        end
                        stime   = "#{shr}#{min}"
                        etime   = "#{hr}#{min}"
#                        puts "Time -> #{stime} - #{etime}"
                    end
                end
            end
        end

#         puts "Item #{i} -> #{items[i].split("\n").join("-")}" unless items[i] == nil
#         ##puts "Item #{i} -> #{items[i]}" unless items[i] == nil
#         puts "" unless items[i] == nil

        if not items[i] == nil
#             puts "Item -> #{items[i]}"
#             puts "Year  -> #{year}"
#             puts "Month -> #{month}"
#             puts "Date  -> #{date}"
#             puts "Start -> #{shr}#{min}"
#             puts "End   -> #{hr}#{min}"


            # http://icalendar.rubyforge.org/
            event = Event.new
            if shr == nil
                event.start = Date.new(year.to_i, month.to_i, date.to_i)
                event.end   = Date.new(year.to_i, month.to_i, date.to_i)
            else
                event.start = DateTime.civil(year.to_i, month.to_i, date.to_i, shr.to_i, min.to_i)
                event.end   = DateTime.civil(year.to_i, month.to_i, date.to_i, hr.to_i, min.to_i)
            end
            event.summary = "#{items[i].split("\n").first}"
            event.description = "#{items[i].split("\n").join("-")}"
            cal.add_event(event)
        end

    end
end 

HELP_STRING =<<EOS

So you thought you would like to go to the show. Usage:

    parse_cal.rb [nmonth] [nyear]

where 'nmonth' is the month number (e.g. March = 03)
and   'nyear'  is the year (e.g. 2009)

EOS

if (not ARGV.grep(/-h|--help/).empty?) or (ARGV.size < 2)
    puts HELP_STRING
    exit(0)
end

if ARGV[0]
    nmonth = ARGV[0]
end
if ARGV[0]
    nyear = ARGV[1]
end

cal = Calendar.new
timezone = Icalendar::Timezone.new
timezone.timezone_id = "America/New_York"
cal.add(timezone)
cal.ip_method = "PUBLISH"

cal_url = "http://calendar.cs.cmu.edu/scsEvents/oneMonth/#{nyear}-#{nmonth}.html"

# instantiate/initialise web agent ..
agent = WWW::Mechanize.new
# .. and get the weblog statistics page
page = agent.get(cal_url)
# parse it!
doc = Hpricot(page.body)

#puts doc.search("//table[@border='0' @cellspacing='0' @cellpadding='5']").first

doc.search("//table[@border='0']").each do |tab|
    if tab["cellspacing"] =='0' and tab["cellpadding"] =='5'
        #puts tab
        if tab
            # extract the statistics data from the <tr> elements
            b_new_day = true
            items = nil
            tab.search("tr").each do |tr|
                if b_new_day
                    b_new_day = false
                    items = []
                end
                tr.search("td").each do |td|
                    if td 
                        str = td.inner_text.strip()
                        if not str == "?"
                            #puts "-----"
                            #puts str
                            #puts str.split("\n").first
                            #items << str
                            if str == "* * * * *"
                                b_new_day = true 
                                dump_day(items, nyear, nmonth, cal)
                            else
                                items << str
                                #puts items.size
                            end
                        end
                    end
                end
            end
        end
    end
end

cal_string = cal.to_ical
puts cal_string
