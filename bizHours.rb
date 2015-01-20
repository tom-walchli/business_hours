#####################################################
#    												#
#  A routine that returns a Time object after       #
#  predefined elapsed duration respecting business 	#
#  hours, special daily hours and holidays.			#
# 													#
#####################################################
require 'time'

class BusinessHours
	attr_reader	:openDayHash
	def initialize(dailyStart,dailyEnd)
		@days 				= [:mon,:tue,:wed,:thu,:fri,:sat,:sun]
		@wdays    			= {0 => :sun, 1 => :mon, 2 => :tue, 3 => :wed, 4 => :thu, 5 => :fri, 6 => :sat, }
		@openDayHash 		= {}
		@openSpecialHash 	= {}
		@closedDayHash	 	= {}
		@closedSpecialHash 	= {}

		@days.each {|day| @openDayHash[day] = [day , dailyStart , dailyEnd]}
	end

	def correct_am_pm(value)
		splt = value.split(" ")
		splt2 = splt[0].split(":")
		return "#{splt2[0].to_i + (splt[1]=="PM" ? 12:0)}:#{splt2[1]}"
	end

	def update(day,t_start, t_end)
		updHashes(:open,day,t_start, t_end)
	end
	def closed(*args)
		args.each {|day| updHashes(:close,day,0, 0)}
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
				if @closedDayHash[day]
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
		puts getDate(Time.new)
	end

	def calculate_deadline(date, duration = 7200)
		@startTime  = Time.parse(date)
		@duration   = duration
		@secsToGo	= duration

		timecount   = 0

		#increment by multiples of 1 second
		speedUp		= 60

		while @secsToGo >= 0
			@secsToGo -= (speedUp * evaluate(timecount))
			if timecount%600 == 0
				puts "Elapsed: #{timecount}\ttoGo: #{@secsToGo}\t#{@startTime+timecount}"
			end
			timecount += speedUp
		end
		puts "\nYour stuff will be ready on #{@startTime + timecount}."
	end

	def evaluate(timeCount)
		currTime = @startTime + timeCount
		wday 	 = currTime.wday
		timeOK   = false
		checkOK	 = false
		openThisDay = @openDayHash[@wdays[wday]]
		t1 = getDateTime(currTime.year, currTime.month, currTime.day, correct_am_pm(openThisDay[1]))
		t2 = getDateTime(currTime.year, currTime.month, currTime.day, correct_am_pm(openThisDay[2]))
		if @openDayHash[@wdays[wday]]
			if currTime.between?(t1,t2)
				checkOK = true
			end
		end
		openSpecial = @openSpecialHash[getDate(currTime)]
		if openSpecial 
			checkOK = false
	 		t1 = getDateTime(currTime.year, currTime.month, currTime.day, correct_am_pm(openSpecial[1]))
			t2 = getDateTime(currTime.year, currTime.month, currTime.day, correct_am_pm(openSpecial[2]))
			if currTime.between?(t1,t2)
				checkOK = true
			end
		end

		if @closedDayHash[wday[wday]]
			checkOK = false
		end

		closedSpecial = @closedSpecialHash[getDate(currTime)]
		if closedSpecial
			checkOK = false
		end

		if checkOK 
			return 1
		end
		return 0
	end

	def getDateTime(year, month, day, time)
		return Time.new(year, month, day, time)
	end
	def getDate(date)
		return "#{date.strftime("%B")[0..2]} #{date.day}, #{date.year}"
	end
end

hours = BusinessHours.new("9:00 AM", "3:00 PM")
hours.update(:fri, "10:00 AM", "5:00 PM")
hours.update("Dec 24, 2010", "8:00 AM", "1:00 PM")
hours.closed(:sun, :wed, "Dec 25, 2010")


#hours.calculate_deadline("Jun 7, 2010 9:10 AM") # => Mon Jun 07 11:10:00 2010
hours.calculate_deadline("Jun 8, 2010 2:48 PM") # => Thu Jun 10 09:03:00 2010
#hours.calculate_deadline("Dec 24, 2010 6:45 AM") # => Mon Dec 27 11:00:00 2010
