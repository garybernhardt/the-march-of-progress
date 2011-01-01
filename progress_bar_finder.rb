# progress_bar_finder.rb
# TheMarchOfProgress
#
# Created by Gary Bernhardt on 12/31/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

framework 'Foundation'
framework 'ScriptingBridge'

class GRBProgressBarFinder
	def find
		events = SBApplication.applicationWithBundleIdentifier('com.apple.systemevents')
		processes = events.applicationProcesses.get()
		processes.map do |process|
			ProcessIndicatorFinder.new(process).indicators
		end.flatten
	end
	
	def real_methods(obj)
		return (obj.methods(true, true) - NSObject.methods(true, true)).sort
	end
end


class ProcessIndicatorFinder
	def initialize(process)
		@process = process
	end
	
	def indicators
		windows = @process.windows.get()
		windows.map do |window|
			WindowIndicatorFinder.new(@process, window).indicators
		end
	end
end


class WindowIndicatorFinder
	def initialize(process, window)
		@process = process
		@window = window
	end
	
	def indicators
		indicators_from_element(@window)
	end
	
	def indicators_from_element(element)
		immediate_indicators = self.immediate_indicators(element)
		children = element.scrollAreas.get()
		if children.empty?
			child_indicators = []
		else
			child_indicators = children.map do |child|
				indicators_from_element(child)
			end
		end
		
		immediate_indicators + child_indicators
	end
	
	def immediate_indicators(element)
		indicators = element.progressIndicators.get()
		indicators.map do |indicator|
			{
				'process_name' => @process.name,
				'window_name' => @window.name,
				'percent' => percent_for_indicator(indicator)
			}
		end
	end
	
	def percent_for_indicator(indicator)
		attributes = indicator.attributes.get
		value = get_attribute(attributes, 'AXValue')
		max = get_attribute(attributes, 'AXMaxValue')
		return (100.0 * value / max).to_i
	end
	
	def get_attribute(attributes, name)
		attribute = attributes.select do |attr|
			attr.name == name
		end.first
		attribute.value.get
	end
end
