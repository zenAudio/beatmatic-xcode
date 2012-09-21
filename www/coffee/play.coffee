class play
	loopTimers: {}
	swipeSampleLayover: false
	swipeVolumeLayover: false
	
	lastSample: false
	originalbpm: false
	direction: false
	lastDistance: 0
	colCache: {}
	
	constructor: ->
		###
		$("#snext").click =>
			#@stopLoop()
			BEATmatic.ui.switch("dj")
			BEATmatic.sequencer.highlightPlayer = false
			false
		
		$("#sback").click =>
			#@stopLoop()
			BEATmatic.sequencer.stopCoreLoop()
			BEATmatic.ui.switch("main")
			BEATmatic.sequencer.highlightPlayer = false
			false
		###	
		
		$("#bars").click (e) =>
			console.log window.e1 = e
			console.log score = e1.target.classList[0][4...]
			console.log track = e1.target.parentElement.id[4...]
			cell =  $ e1.target
			
			if cell.hasClass "hit"
				cell.removeClass "hit"
				BEATmatic.sequencer.drumTracks.tracks[track - 1].score[score - 1] = 0
			else
				cell.addClass "hit"
				
				BEATmatic.sequencer.drumTracks.tracks[track - 1].score[score - 1] = 100
		###	
		click: (e, target) =>
			score = e.target.cellIndex + 1
			track = e.target.parentNode.rowIndex
			
			cell = $($(".c#{score}")[track])
			if cell.hasClass "x100"
				cell.removeClass "x100"
				BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 0
			else
				cell.addClass "x100"
				
				BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 100
		
		###
		@setup("demo")
		
	setup: (data) =>		
		if data is "demo"
			data =
					"project": "House Beat 1",
					"bpm": 130,
					"tracks":
						[
								"name": "kick drum"
								"sample": "kick01.wav"
								"icon": "kickdrum.png"
								"score": [100,0,0,0,  0,0,0,100,  100,0,0,0,  0,0,0,0]
						#"SD":
							,
								"name": "snare drum"
								"sample": "snare01.wav"
								"icon": "snaredrum.png"
								"score": [0,0,0,0,    100,0,0,0,   0,0,0,0,   100,0,0,0]
						#"HH":
							,
								"name": "hi hat"
								"sample": "hihat01.wav"
								"icon": "hihat.png"
								"score": [0,0,100,0,  0,0,100,0,  0,0,100,0,   0,0,100,0]
						]

		@generateHTML()
		#BEATmatic.sequencer.highlightPlayer = true
		#@loopTracks()
		
		
		BEATmatic.audioEngine.init "sounds/drummachine/defpreset/preset.json", "sounds/looper/defpreset/preset.json"
		console.log "MPD:HTML:onDeviceReady: initialized drum preset."
		json = JSON.stringify(data)
		console.log "MPD:HTML:onDeviceReady: about to set drum pattern to " + json
		BEATmatic.audioEngine.setDrumPattern json
		
		
		BEATmatic.audioEngine.setCursorCallback (cursorPosJson) ->
		  
		  console.log("MPD: JS: playback cursor: " + cursorPosJson);
		  time = JSON.parse(cursorPosJson)
		  #$("#timeKeeper").text time.bars + "." + time.beats + "." + time.ticks
		  #@highlightTick
		
		#BEATmatic.audioEngine.play()
	
	
	generateHTML: =>
		html = ""
		
		for score1, index in BEATmatic.sequencer.drumTracks.tracks[0].score
			score2 =BEATmatic.sequencer.drumTracks.tracks[1].score[index]
			score3 =BEATmatic.sequencer.drumTracks.tracks[2].score[index]
			
			html = """#{html}<div id="tick#{index+1}"class="wrapper">
			     <div class="left1 #{if score1 then "hit" else ""}">
			     </div>
			     <div class="left2 #{if score2 then "hit" else ""}">
			     </div>
			     <div class="left3 #{if score3 then "hit" else ""}">
			     </div>
			 </div>"""
		
		
		$("#bars").html html
		#@enableSwipe()
	
	highlightTick: (col) ->
		@highcol.removeClass "high" if @highcol
		@highcol = $("#tick"+col)
		@highcol.addClass "high"
	
	###	
	enableSwipe: =>	
		$("#hor-minimalist-a").swipe
			click: (e, target) =>
				score = e.target.cellIndex + 1
				track = e.target.parentNode.rowIndex
				
				cell = $($(".c#{score}")[track])
				if cell.hasClass "x100"
					cell.removeClass "x100"
					BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 0
				else
					cell.addClass "x100"
					
					BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 100
		
			swipeStatus: (e, phase, direction, distance) =>
				#swipeCount++
				if phase is "cancel" or phase is "end"
					@direction = false
					@lastDistance = 0
					
					if @swipeSampleLayover
						$("#swipeSampleLayover").hide()
						@swipeSampleLayover = false
						BEATmatic.sequencer.stopCoreLoop()
						BEATmatic.sequencer.startCoreLoop()
						
					if @swipeVolumeLayover
						$("#swipeVolumeLayover").hide()
						@originalbpm = false
						@swipeVolumeLayover = false
					return
				
				if distance <= 5
					return

				
				
				if direction is "up" or direction is "down"
					@direction = "updown" unless @direction
					return if "updown" != @direction
					
					unless @swipeSampleLayover
						#@stopLoop()
						BEATmatic.sequencer.stopCoreLoop()
						@swipeSampleLayover = true
						
						$("#swipeSampleLayover").show()
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
					
					
					
					if direction is "up"
						n++ unless n >= 7
						
					
					if direction is "down"
						n-- unless n <= 1
						
					
					newsample = @samplebase + 0 + n + sample[i+2...]
					#return
					BEATmatic.sequencer.playAudio BEATmatic.sequencer.folder + "drums/" +  newsample
					BEATmatic.sequencer.drumTracks.tracks[track].sample = newsample
					
					$("#swipeSampleLayover").html(newsample)
					
						
				if direction is "left" or direction is "right"
					@direction = "leftright" unless @direction
					return if "leftright" != @direction
					
					unless @swipeVolumeLayover
						$("#swipeVolumeLayover").show()
						@swipeVolumeLayover = true
					
					offset = Math.round (distance / 2)
					
					if direction is "left"
						offset = offset * -1
					
					@originalbpm = BEATmatic.sequencer.BPM unless @originalbpm
					
					$("#swipeVolumeLayover").html "#{@originalbpm + offset} BPM"

					BEATmatic.sequencer.changeBPM @originalbpm + offset
					
				
				return
				
			allowPageScroll: "none"
			threshold: 50
		

	getCols: (col) ->
		return $(".c#{col}")
		if @colCache[col]?
			return @colCache[col]
		else
			return @colCache[col] = $(".c#{col}")		
	
	highlightColumn: (col) ->
		@getCols(col).addClass "highlighted"
		col = col - 1
		col = 16 if col is 0
		@getCols(col).removeClass "highlighted"
		
	###
			

delay = (ms, func) ->
	setTimeout func, ms

$ ->
	BEATmatic.play = new play()
	#vid = document.getElementById("my-video")
	#vid.defaultPlaybackRate = 2.0;
	#$("my-video").prop('muted', true)
	#vid.play();
	#delay 3000, ->
	#	vid.playbackRate = 3.0;
	