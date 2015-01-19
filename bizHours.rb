#####################################################
#    												#
#  A routine that returns a Time object after after	#
#  predefined elapsed duration respecting business 	#
#  hours, daily special hours and holidays.			#
#  Time an order has after  						#
# 													#
#####################################################

class BusinessHours
	attr_reader	:openDayHash
	def initialize(dailyStart,dailyEnd)
		@days 				= [:mon,:tue,:wed,:thu,:fri,:sat,:sun]
		@openDayHash 		= {}
		@openSpecialHash 	= {}
		@closedDayHash	 	= {}
		@closedSpacialHash 	= {}

		@days.each {|day| @openDayHash[day] = [day , dailyStart , dailyEnd]}
		p @openDayHash
	end

	def update(day,t_start, t_end)
		updHashes(:open,day,t_start, t_end)
	end
	def closed(*args)
		args.each {|day| updHashes(:close,day,t_start, t_end)}
	end

	def updHashes(open_or_close,day,t_start, t_end)
		case open_or_close
		when :open
			if @days.include? day 
				puts "Updating open #{day} from #{@openDayHash[day][1]}-#{@openDayHash[day][2]} to #{t_start}-#{t_end}"
				@openDayHash[day] 	= [day,t_start,t_end]
				return
			end
			if @openSpecialHash[day] 
				puts "Updating open #{day} from #{@openSpecialHash[day][1]}-#{@openSpecialHash[day][2]} to #{t_start}-#{t_end}"
			end
			@openSpecialHash[day] 	= [day,t_start,t_end]
		when :close
			if @days.include? day 
				if closedDayHash[day]
					puts "Updating closed #{day} (actually, there's no change...)"
				else
					puts "Adding closed #{day}"
				end
				@closedDayHash[day] = [day]
				return
			end
			if @closedSpecialHash[day] 
				puts "Updating closed #{day} (actually, there's no change...)"
			else
				puts "Adding closed #{day}"
			end
			@closedSpecialHash[day] = [day]
		end
	end

	def calculate_deadline(date, duration = 7200)
		@startTime  = Time.new(date)
		@duration   = duration
		@secsToGo	= duration

		timecount = 0
		while @secsToGo > 0
			@secsToGo += evaluate(@startTime,timecount)
			timecount += 1
		end
	end

	def evaluate(startTime,timecount)
#		return 0
#		return -1
	end
end

hours = BusinessHours.new("9:00 AM", "3:00 PM")
hours.update(:fri, "10:00 AM", "5:00 PM")
hours.update("Dec 24, 2010", "8:00 AM", "1:00 PM")
hours.closed(:sun, :wed, "Dec 25, 2010")



