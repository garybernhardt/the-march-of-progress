# dummy_progress_indicator.rb
# TheMarchOfProgress
#
# Created by Gary Bernhardt on 12/31/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class GRBDummyProgressIndicator
	attr_accessor :progressIndicator

	def awakeFromNib
		@progressIndicator.setDoubleValue(50)
		@progressIndicator.startAnimation(self)
	end
end