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
	
	def crawl_element(element)
		my_indicator_count = element.buttons.count
		child_indicator_count = 0
		children = element.UIElements.get()
		return my_indicator_count if children.empty?
		children = element.UIElements.get() or []
		child_indicator_counts = children.map do |element|
			child_indicator_count += crawl_element(element)
		end
		return my_indicator_count + child_indicator_count
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
			indicators_from_window(window)
		end
	end
	
	def indicators_from_window(window)
		window_name = window.name
		indicators = window.progressIndicators.get()
		indicators.map do |indicator|
			{
				'process_name' => @process.name,
				'window_name' => window_name,
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