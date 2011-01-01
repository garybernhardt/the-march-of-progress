# progress_list_controller.rb
# TheMarchOfProgress
#
# Created by Gary Bernhardt on 12/31/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'timeout'
require 'progress_bar_finder'

class GRBProgressList
	attr_reader :values
	
	def initialize
		@start = Time.now
		self.update
		Thread.new {
			loop {
				sleep 0.2
				self.update
			}
		}
	end
	
	def update
		indicators_by_process = GRBProgressBarFinder.new.find
		values = []
		indicators_by_process.each_pair do |process_name, indicators|
			values << {'name' => process_name, 'percent' => indicators.to_s}
		end
		self.setValue(values, :forKey => 'values')
	end
		
	def firstIndex
		raise "BAR"
	end
	
	def values
		@values
	end
	
	def setValues(values)
		@values = values
	end
end
