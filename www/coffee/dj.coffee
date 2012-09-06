class dj
	swipeSampleLayover: false
	swipeVolumeLayover: false
	
	lastSample: false
	originalbpm: false
	direction: false
	lastDistance: 0
	
	constructor: ->
		#BEATmatic.sequencer.
		
		
		$(".returnbtn").click ->
			BEATmatic.sequencer.stopCoreLoop()
			BEATmatic.ui.switch("main")
			false
		
		@setupClickHandlers()
		#@enableSwipe()

	
	setupClickHandlers: ->
		#console.log "setupClickHandlers"
		for button in $(".djbtn")#.each
			@setupClickHandler button#(this).name
	
	setupClickHandler: (button) ->
		button = $ button
		#console.log button
		button.click @clickHandler
		
	resetButtons: ->
		for btn in $(".djbtn")
			btn = $ btn
			btnname = btn.attr("name")
			i = btnname.indexOf "."
			btnbase = btnname[...i]
			
			if btnbase is "drums"
				btn.addClass "active"
			else
				btn.removeClass "active"
			
	toggleButtonState: (button) ->
		if button.hasClass "active"
			button.removeClass "active"
		else
			button.addClass "active"
			
	clickHandler: (e) =>
		#console.log "clickHandler"
		btn =  window.b1 = $ e.currentTarget
		btnname = btn.attr("name")
		i = btnname.indexOf "."
		btnbase = btnname[...i]
		btnspecific = btnname[i+1...]
		
		@[btnbase + "Toggle"]?(btnspecific, btn)
		#console.log btn
		if btn.hasClass "active"
			#return if 
			@[btnbase + "Off"]?(btnspecific, btn)
		else
			#return if 
			@[btnbase + "On"]?(btnspecific, btn)
			
		@toggleButtonState btn
	
	
	
	drumsOn: (drum, btn) ->
		switch drum
			when "kickdrum" then BEATmatic.sequencer.unMuteDrum 0
			when "snare" then BEATmatic.sequencer.unMuteDrum 1
			when "hihat" then BEATmatic.sequencer.unMuteDrum 2
			else console.log "unknown drum"
		false	
	
	
	drumsOff: (drum, btn) ->
		switch drum
			when "kickdrum" then BEATmatic.sequencer.muteDrum 0
			when "snare" then BEATmatic.sequencer.muteDrum 1
			when "hihat" then BEATmatic.sequencer.muteDrum 2
			else console.log "unknown drum"
		false
	
	
		
	sampleOn: (sample, btn) ->
		#console.log "sampleOn"
		BEATmatic.sequencer.playSample sample
		#BEATmatic.sequencer.sampleTacksToPlay.push sample
		false
	
	sampleOff: (sample, btn) ->
		BEATmatic.sequencer.stopSample sample
		#i = $.inArray(sample, BEATmatic.sequencer.sampleTacksToPlay)
		#return  if i is -1
		#BEATmatic.sequencer.sampleTacksToPlay.splice i, 1
		false
	
	enableSwipe: =>	
		$("#dj").swipe
			click: (e, target) =>
				true
			###
			click: (e, target) =>
				score = e.target.cellIndex
				track = e.target.parentNode.rowIndex
				
				cell = $($(".c#{score}")[track])
				if cell.hasClass "x100"
					cell.removeClass "x100"
					BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 0
				else
					cell.addClass "x100"
					
					BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 100
			###
		
			swipeStatus: (e, phase, direction, distance) =>
				#swipeCount++
				if phase is "cancel" or phase is "end"
					@direction = false
					@lastDistance = 0
					
					if @swipeSampleLayover
						$("#swipeDJSampleLayover").hide()
						@swipeSampleLayover = false
						BEATmatic.sequencer.stopCoreLoop()
						BEATmatic.sequencer.startCoreLoop()
						
					if @swipeVolumeLayover
						$("#swipeDJVolumeLayover").hide()
						@originalbpm = false
						@swipeVolumeLayover = false
					return
				
				if distance <= 5
					return
				###
				if direction is "left" or direction is "right"
					@direction = "leftright" unless @direction
					return if "leftright" != @direction
						
					unless @swipeSampleLayover
						#@stopLoop()
						BEATmatic.sequencer.stopCoreLoop()
						@swipeSampleLayover = true
						
						$("#swipeDJSampleLayover").show()
						@samplebase = false

					
					unless @lastUpDownDirection is direction
						@lastDistance = distance
						@lastUpDownDirection = direction
					
					move = distance - @lastDistance
					
					
					#mouse move above 10px or below -10
					if (move < 10) and (move > -10)
						#console.log "did not move enough"
						#console.log move
						return

											
					@lastDistance = distance
					
					track = e.target.parentNode.rowIndex
					sample = BEATmatic.sequencer.drumTracks.tracks[track].sample
					i = sample.indexOf "0"
					n = Number sample[i+1]
					unless @samplebase
						@samplebase = sample[...i]
					
					
					
					if direction is "left"
						n++ unless n >= 7
						
					
					if direction is "right"
						n-- unless n <= 1
						
					
					newsample = @samplebase + 0 + n + sample[i+2...]
					#return
					BEATmatic.sequencer.playAudio BEATmatic.sequencer.folder + "drums/" +  newsample
					BEATmatic.sequencer.drumTracks.tracks[track].sample = newsample
					
					$("#swipeDJSampleLayover").html(newsample)
				###	
						
				if direction is "up" or direction is "down"
					@direction = "updown" unless @direction
					return if "updown" != @direction
					
					unless @swipeVolumeLayover
						$("#swipeDJVolumeLayover").show()
						@swipeVolumeLayover = true
					
					offset = Math.round (distance / 2)
					
					if direction is "down"
						offset = offset * -1
					
					@originalbpm = BEATmatic.sequencer.BPM unless @originalbpm
					
					$("#swipeDJVolumeLayover").html "#{@originalbpm + offset} BPM"

					BEATmatic.sequencer.changeBPM @originalbpm + offset
					
				
				return
				
			allowPageScroll: "none"
			threshold: 50

	

$ ->
	BEATmatic.dj = new dj()
