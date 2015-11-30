#!/usr/bin/ruby

require 'statsample'
require 'optparse'

# test code on statsample for mean and median!
y = [1, 2, 3, 4, 1, 5].to_vector
puts 'Mean of this sample is: ', y.mean
puts 'Median of this sample is: ', y.median

# code to parse the command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
	opts.on("-i=INPUT", "--input-file=INPUT", "Input file path") do |i|
		options[:input_file] = i
		if not i
			p "You need to pass an input file!"
		end
	end
end.parse!

VERBOSE = options[:verbose]

if VERBOSE
	p "Options read from the command line:"
	p options
end

# do not allow user to proceed without input file
if not options[:input_file]
	puts "You need to supply an input file path"
	exit
end

# initialise the variables
start_reading = false
all_times = Array.new

# read the input file
File.open(options[:input_file], "r") do |filin|
	while(line = filin.gets)
		if not start_reading and /Time\sList/.match(line)
			start_reading = true
		end

		if start_reading
			matches = line.scan(/\d{2}.\d{2}/)
			matches.each do |match|
				all_times.push(match.to_f)
			end
		end
	end
end

if VERBOSE
	p all_times.count.to_s + " solve times read from the input file"
end

# start calculating stats stuff!

main_vector  = all_times.to_vector
@all_times   = all_times
@main_vector = main_vector

def basic_stats
	p '----------------------------'
	p '----------------------------'
	p '-------- STATISTICS --------'
	p 'Mean of the solvetimes   : %0.2f' % @main_vector.mean
	p 'Median of the solvetimes : %0.2f' % @main_vector.median
	p 'Best solvetime           : %0.2f' % @main_vector.min
	p 'Worst solvetime          : %0.2f' % @main_vector.max
	p 'Mode solvetime           : %0.2f' % @main_vector.mode
end

def build_histogram
	p @all_times.count
	h = @all_times.to_vector(:scale)
	svg_xml_output = Statsample::Graph::Histogram.new(h).to_svg
	p 'A histogram must have opened up!'
	rb = ReportBuilder.new
	rb.add(Statsample::Graph::Histogram.new(h))
	rb.save_html('histogram.html')
end

build_histogram
