class dj
	btns: []
	
	constructor: ->
		""
		
	setup: ->
		for x in [1..9]
			@btns.push new BEATmatic.SoundBtn $("#music2"), "btn-drum", "#24A2E2"
		#@btns
		@playAll()			
			
	playAll: ->
		for btn in @btns
			btn.play()
		
		
	stop: ->
		for btn in @btns
			btn.stop()
		console.log "BTNS stopped"

class djOLD
	swipeSampleLayover: false
	swipeVolumeLayover: false
	
	lastSample: false
	originalbpm: false
	originalTarget: false
	direction: false
	lastDistance: 0
	
	constructor: ->
		#BEATmatic.sequencer.
		
		
		$(".returnbtn").click ->
			BEATmatic.sequencer.stopCoreLoop()
			BEATmatic.ui.switch("main")
			false
		
		#@setupClickHandlers()
		@enableSwipe()

	###
	setupClickHandlers: ->
		#console.log "setupClickHandlers"
		for button in $(".djbtn")#.each
			@setupClickHandler button#(this).name
	
	setupClickHandler: (button) ->
		button = $ button
		#console.log button
		button.click @clickHandler
	###

		
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
	
	#buttonFromEvent: (e) ->
		
			
	clickHandler: (e) =>
		btn = $ e.target
		return unless btn.hasClass "djbtn"
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
		
	changeSample: (e, target, negative) =>
		console.log "changeSample called #{negative}"
		btn = $ target
		unless btn.hasClass "djbtn"
			if btn.parent().hasClass "djbtn"
				btn = btn.parent()
			else
				return
		
		#console.log btn.childElementCount
		return unless btn.children().length is 1
		
		btnname = btn.attr("name")
		i = btnname.indexOf "."
		btnbase = btnname[...i]
		btnspecific = btnname[i+1...]
		
		currentButtonTextNumber = Number(btn.find("h1").text()[1])
		console.log currentButtonTextNumber
		
		if negative
			btn.find("h1").text "#" + (currentButtonTextNumber - 1)
		else
			btn.find("h1").text "#" + (currentButtonTextNumber + 1)
		
	
	
	
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
		BEATmatic.sequencer.sampleTracks[sample].callbacks.push =>
			btn.removeClass "active"
		false
	
	sampleOff: (sample, btn) ->
		BEATmatic.sequencer.stopSample sample
		#i = $.inArray(sample, BEATmatic.sequencer.sampleTacksToPlay)
		#return  if i is -1
		#BEATmatic.sequencer.sampleTacksToPlay.splice i, 1
		false
	
	enableSwipe: =>	
		$("#dj").swipe
			#click: (e, target) =>
			#	true
			
			click: (e, target) =>
				BEATmatic.dj.clickHandler(e)
			
		
			swipeStatus: (e, phase, direction, distance) =>
				console.log direction
				console.log distance
				#swipeCount++
				if phase is "cancel" or phase is "end"
					@direction = false
					@lastDistance = 0
					
					if @swipeSampleLayover
						$("#swipeDJSampleLayover").hide()
						@swipeSampleLayover = false
						@originalTarget = false
						#BEATmatic.sequencer.stopCoreLoop()
						#BEATmatic.sequencer.startCoreLoop()
						
					if @swipeVolumeLayover
						$("#swipeDJVolumeLayover").hide()
						@originalbpm = false
						@swipeVolumeLayover = false
					return
				
				return if distance <= 5
				#console.log distance
				
				if direction is "left" or direction is "right"
					
					
					return if distance <= 5
						
					
					@direction = "leftright" unless @direction
					return if "leftright" != @direction
					
					
					unless @swipeSampleLayover
						@swipeSampleLayover = true
						$("#swipeDJSampleLayover").show()
						@samplebase = false
					
					@originalTarget = e.target unless @originalTarget
					
					#console.log @originalTarget.childElementCount
						
					#return unless @originalTarget.childElementCount is 1
					
					BEATmatic.dj.changeSample e, @originalTarget, (distance < 0)
					###	
					if direction is "left"
						
					
					if direction is "right"

					unless @lastLeftRightDirection is direction
						@lastDistance = distance
						@lastLeftRightDirection = direction
					
					move = distance - @lastDistance
					
					
					#mouse move above 10px or below -10
					if (move <= 10) and (move > -10)
						#console.log "did not move enough"
						#console.log move
						return
							
					@lastDistance = distance
					
					BEATmatic.dj.changeSample e, (distance < 0)
					return
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
