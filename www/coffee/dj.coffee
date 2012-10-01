class dj
	btns: []
	isSetUp: false
	drumPatternA: false
	drumPatternB: false
	drumPatternC: false
	
	constructor: ->
		""
		#@setup()
		
		
	setup: ->
		unless @isSetUp
			
			#drums
			@addGroup "dj-drums", 5, 10, 2
			btn = new BEATmatic.SoundBtn $("#dj-drums"), "btn-drums", "#24A2E2", ->
				#UGLY -> there should be a way to mute a drum track
				@toggle()
				if @drumPatternA
					BEATmatic.drumPattern.tracks[0].score = @drumPatternA
					BEATmatic.drumPattern.tracks[1].score = @drumPatternB
					@drumPatternA = false
				else
					@drumPatternA = BEATmatic.drumPattern.tracks[0].score
					@drumPatternB = BEATmatic.drumPattern.tracks[1].score
					BEATmatic.drumPattern.tracks[0].score = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
					BEATmatic.drumPattern.tracks[1].score = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
				BEATmatic.audioEngine.applyDrumPattern()
			btn.animations = false
			btn.play()
			@btns.push btn	
			btn = new BEATmatic.SoundBtn $("#dj-drums"), "btn-hihat", "#F523A1", ->
				#UGLY -> there should be a way to mute a drum track
				@toggle()
				if @drumPatternC
					BEATmatic.drumPattern.tracks[2].score = @drumPatternC
					@drumPatternC = false
				else
					@drumPatternC = BEATmatic.drumPattern.tracks[2].score
					BEATmatic.drumPattern.tracks[2].score = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
				BEATmatic.audioEngine.applyDrumPattern()
			btn.animations = false
			btn.play()
			@btns.push btn	
			@addHeadline $("#dj-drums"), "Basic Beat", "#24A2E2"
			
			
			#Scene A
			@addGroup "dj-beata", 100, 10, 1
			btnsBeatA = []
			A = new BEATmatic.Btn $("#dj-beata"), "btn-beata", "#CACACA", ->
				for btn in btnsBeatA
					btn.btnFunction()
			btn = new BEATmatic.SoundBtn $("#dj-beata"), "btn-bass", "#F19917", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Bass", 0)
			@btns.push btn
			btnsBeatA.push btn
			btn = new BEATmatic.SoundBtn $("#dj-beata"), "btn-lead", "#8CBF26", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Lead", 0)
			@btns.push btn
			btnsBeatA.push btn
			@addHeadline $("#dj-beata"), "Scene A", "#CACACA"
			
			
			#Scene B
			@addGroup "dj-beatb", 100, 80, 1
			btnsBeatB = []
			B = new BEATmatic.Btn $("#dj-beatb"), "btn-beatb", "#CACACA", ->
				for btn in btnsBeatB
					btn.btnFunction()
			
			btn = new BEATmatic.SoundBtn $("#dj-beatb"), "btn-bass", "#F19917", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Bass", 1)
			@btns.push btn
			btnsBeatB.push btn
			btn = new BEATmatic.SoundBtn $("#dj-beatb"), "btn-lead", "#8CBF26", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Lead", 1)
			@btns.push btn
			btnsBeatB.push btn
			@addHeadline $("#dj-beatb"), "Scene B", "#CACACA"
			
			@addGroup "dj-perc", 5, 165, 1
			@btns.push new BEATmatic.SoundBtn $("#dj-perc"), "btn-percussion", "#339933", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Percussion", 0)
			@addHeadline $("#dj-perc"), "Percussion", "#339933"
			
			@addGroup "dj-fill", 5, 232, 1
			@btns.push new BEATmatic.SoundBtn $("#dj-fill"), "btn-fill", "#E671B8", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Fills", 0)
			@addHeadline $("#dj-fill"), "Fill", "#E671B8"
			
			@addGroup "dj-voc", 100, 165, 2
			@btns.push new BEATmatic.SoundBtn $("#dj-voc"), "btn-vocal", "#00ABA9", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Vocals", 0)

			@btns.push new BEATmatic.SoundBtn $("#dj-voc"), "btn-vocal", "#00ABA9", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Vocals", 1)
			@addHeadline $("#dj-voc"), "Vocals", "#00ABA9"
			
			@addGroup "dj-ear", 195, 165, 2
			@btns.push new BEATmatic.SoundBtn $("#dj-ear"), "btn-candy", "#E51400", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Ear Candy", 0)
			@btns.push new BEATmatic.SoundBtn $("#dj-ear"), "btn-candy", "#E51400", ->
				@toggle()
				BEATmatic.audioEngine.toggleLoop("Ear Candy", 1)
			@addHeadline $("#dj-ear"), "Ear Candy", "#E51400"
			
			@addGroup "dj-fx", 290, 165, 2
			@btns.push new BEATmatic.SoundBtn $("#dj-fx"), "btn-fx", "#AD31FF", ->
				@toggle()
				#@playing = not @playing
				BEATmatic.audioEngine.setMasterFilter(@playing)
			@btns.push new BEATmatic.SoundBtn $("#dj-fx"), "btn-fx", "#AD31FF", ->
				@toggle()
				BEATmatic.audioEngine.setMasterCrusher(@playing)
			@addHeadline $("#dj-fx"), "FX", "#AD31FF"
			
			@addGroup "dj-xx", 385, 10, 4
			X = new BEATmatic.Btn $("#dj-xx"), "btn-back", "#CACACA", ->
				BEATmatic.ui.switch "main"
			@btns.push new BEATmatic.SoundBtn $("#dj-xx"), "btn-drums", "#24A2E2"
			@btns.push new BEATmatic.SoundBtn $("#dj-xx"), "btn-drums", "#24A2E2"
			X = new BEATmatic.SoundBtn $("#dj-xx"), "btn-fwd", "#24A2E2"
			@addHeadline $("#dj-xx"), "todo", "#24A2E2"
			
			###
			for x in [1..10]
				@btns.push new BEATmatic.SoundBtn $("#music2"), "btn-drum", "#24A2E2"
			@addHeadline $("#music2"), "blue!", "#24A2E2"
			
			@btns.push new BEATmatic.SoundBtn $("#music"), "btn-drum", "#FF0097"
			@addHeadline $("#music"), "magenta!", "#FF0097"
			###
			@isSetUp = true
		else
			@stop()
			
		#@playAll()
	
	addGroup: (id, x, y, rows) ->
		$("#dj").append """<div id="#{id}" style="position: absolute; top: #{x}px; left: #{y}px; width: #{rows * 67}px; border: 0px solid blue;"></div>"""
	
	addHeadline: (div, text, color) ->			
		div.append """
		<div class="heading" style="border-bottom: 1px solid #{color};">
		  <h1 style="color: #{color};">#{text}</h1>
		</div>
		"""
			
	playAll: ->
		for btn in @btns
			btn.play()
		
	stop: ->
		for btn in @btns
			btn.stop()

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
