#!/usr/bin/env ruby

require 'statsample'
require 'optparse'
require 'gnuplot'

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
	# Statsample::Graph::Histogram.new(h).to_svg
	p 'A histogram must have opened up!'
	rb = ReportBuilder.new
	rb.add(Statsample::Graph::Histogram.new(h))
	rb.save_html('histogram.html')
end

def build_history_of_averages(num_solves)
	num_datapoints = (@all_times.count / num_solves).to_i
	all_means = Array.new
	for i in 0..num_datapoints
		this_mean = @all_times[i*num_solves..(i+1)*num_solves].to_vector.mean
		all_means.push(this_mean)
	end
	Gnuplot.open do |gp|
		Gnuplot::Plot.new( gp ) do |plot|

			plot.title  "Average of " + num_solves.to_s + " versus time"
			plot.xlabel "time"
			plot.ylabel "ao" + num_solves.to_s

			y = all_means
			x = (1..all_means.count).to_a

			plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
				ds.with = "linespoints"
				ds.notitle
			end
		end
	end
end

def build_graph_of_solve_times
	Gnuplot.open do |gp|
		Gnuplot::Plot.new( gp ) do |plot|

			plot.title  "Solvetime evolution over time"
			plot.xlabel "epochs"
			plot.ylabel "Solve times"

			y = @all_times
			x = (1..@all_times.count).to_a

			plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
				ds.with = "linespoints"
				ds.notitle
			end
		end
	end
end

def build_graph_of_last_few_solve_times(num_solves)
	Gnuplot.open do |gp|
		Gnuplot::Plot.new( gp ) do |plot|

			plot.title  "Last " + num_solves.to_s + " solvetimes"
			plot.xlabel "Epochs"
			plot.ylabel "Solvetime"

			start_index = @all_times.count - num_solves
			end_index = @all_times.count-1

			y = @all_times[@all_times.count-num_solves..@all_times.count-1]
			x = (@all_times.count-num_solves..@all_times.count-1).to_a

			plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
				ds.with = "linespoints"
				ds.notitle
			end
		end
	end
end

# build_histogram
# build_history_of_averages 50
# build_graph_of_solve_times 
build_graph_of_last_few_solve_times 50
