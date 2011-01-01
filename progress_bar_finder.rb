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
		puts "START"
		indicators_by_process = Hash.new(0)
		processes.each do |process|
			#puts (process.methods(true, true) - NSObject.methods(true, true)).sort
			#puts process.UIElements.get()
			#puts "#{process.name} #{process.uielements.get.count}"
			process_name = process.name
			windows = process.windows.get()
			windows.each do |window|
				#puts "COUNT #{process.name} #{window.name} #{crawl_element(window)}"
				#puts "COUNT #{process.name} #{window.name} #{window.progressIndicators.count}"
				indicators = window.progressIndicators.count
				indicators_by_process[process_name] += indicators
			end
		end
		indicators_by_process
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
