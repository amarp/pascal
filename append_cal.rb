#!/usr/bin/ruby

HELP_STRING =<<EOS

So you thought you would like to go to the show. Usage:

    append_cal.rb [nmonth] [nyear]

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

system("./parse_cal.rb #{nmonth} #{nyear} > #{nyear}_#{nmonth}.ical")

if File.exist?("scs.ical")
    nlines = `cat scs.ical | wc -l`
    nlines2 = `cat #{nyear}_#{nmonth}.ical | wc -l`
    head_nlines = (nlines.to_i - 4)
    tail_nlines = (nlines2.to_i - 5)
    system("head -#{head_nlines} scs.ical > scs_new.ical")
    system("mv scs_new.ical scs.ical")
    system("tail -#{tail_nlines} #{nyear}_#{nmonth}.ical >> scs.ical")
else
    system("cat #{nyear}_#{nmonth}.ical > scs.ical")
end
