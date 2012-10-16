class play
	loopTimers: {}
	swipeSampleLayover: false
	swipeVolumeLayover: false
	
	lastSample: false
	originalbpm: false
	direction: false
	lastDistance: 0
	colCache: {}
	
	noClick: false
	
	constructor: ->
		
		
		
		
		#$("#bars").click (e) =>
		#	@clickOnHit(e)# unless @noClick
			
		$("#bars").swipe			
			click: (e, target) =>
				@clickOnHit(e)
		###
		$("#bars").bind 'touchstart',  (e) =>
			@noClick = true
			
			@clickOnHit(e)
			
		@setup2()
		###
	clickOnHit: (e) =>
		track = e.target.classList[0][4...]
		score = e.target.parentElement.id[4...]
		cell =  $ e.target
		
		unless cell[0].className[0..3] is "left"
			return
			
		if cell.hasClass "hit"
			cell.removeClass "hit"
			@changeScore track - 1, score - 1, 0
		else
			cell.addClass "hit"
			@changeScore track - 1, score - 1, 100
	
	changeScore: (track, score, value) =>
		BEATmatic.drumPattern.tracks[track].score[score] = value
		BEATmatic.audioEngine.applyDrumPattern()
	###	
	setup: (data) =>		
		if data is "demo"
			BEATmatic.sequencer.setup
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
		else
			BEATmatic.sequencer.setup data

		@generateHTML()
		BEATmatic.sequencer.highlightPlayer = true
		#@loopTracks()
	###
	setup: =>		
		@generateHTML()
		
		BEATmatic.audioEngine.setCursorCallback (cursorPosJson) =>
			time = JSON.parse(cursorPosJson)
			BEATmatic.play.highlightTick (time.beats - 1 ) * 4 + time.ticks
	
	stopHighlight: ->
		BEATmatic.audioEngine.setCursorCallback false
	
	headline: (text) ->
		color = "#CCCCCC"
		"""
		<div class="heading" style="border-bottom: 1px solid #{color}; padding-right: 20px; margin-right: 20px">
		  <h1 style="color: #{color};">#{text}</h1>
		</div>
		"""
	
	generateHTML: =>
		bars = ""
		playbar = ""
		scrollbar = ""
		
		
		@scoresMax = BEATmatic.drumPattern.tracks[0].score.length
		@ticksOnScreen = Math.round(($(window).height() - 45) / 52)
		
		itemHeight = 100 / @scoresMax
		
		for score1, index in BEATmatic.drumPattern.tracks[0].score
			score2 = BEATmatic.drumPattern.tracks[1].score[index]
			score3 = BEATmatic.drumPattern.tracks[2].score[index]
			#and index != 0
			bars = """#{bars}#{if (index % 4) is 0  then @headline "Beat#{(index)/4+1}" else ""}<div id="tick#{index+1}"class="wrapper">
			     <div class="left1 #{if score1 then "hit" else ""}">
			     </div>
			     <div class="left2 #{if score2 then "hit" else ""}">
			     </div>
			     <div class="left3 #{if score3 then "hit" else ""}">
			     </div>
			 </div>"""
			 
			playbar = """#{playbar}<div id="obar#{index+1}" class="oticks" style="height: #{itemHeight}%;"></div>"""
			scrollbar = """#{scrollbar}<div id="sbar#{index+1}" class="oticks" style="height: #{itemHeight}%;"></div>"""
			#@scoresMax = index + 1

		
		$("#bars").html bars #+ """<div id="spacer" class="wrapper"><br><br><br></div>"""
		
		$("#playbars").html playbar
		$("#scrollbars").html scrollbar
		
		unless @btnAreSetUp
		
			backBtn = new BEATmatic.Btn $("#synthNav"), "btn-back", "#CACACA", ->
				BEATmatic.ui.switch("main")
				false
				
			
			backBtn.el.css "float", "left"
			
			$("#synthNav").append """<div style="float: left;" class="navLabel">Start again</div>"""
			
			fwdBtn = new BEATmatic.Btn $("#synthNav"), "btn-fwd", "#CACACA", ->
				BEATmatic.ui.switch("dj")
				false
				
			fwdBtn.el.css "float", "right"
			$("#synthNav").append """<div style="float: right;" class="navLabel">Perform	</div>"""
			
			@btnAreSetUp = true
		###
		$("#snext").click =>
			BEATmatic.ui.switch("dj")
			false
		
		$("#sback").click =>
			BEATmatic.ui.switch("main")
			false
		###	
			
		fwdBtn.el.css "float", "right"
		
		#@addHeadline $("#dj-controls"), "Controls", "#CACACA"
		
		#@enableSwipe()
		@setupScrollSpy()
	
	setupScrollSpy: =>
		$(".wrapper").each (i) ->
			position = $(this).position()
			#console.log position
			#console.log "min: " + position.top + " / max: " + parseInt(position.top + $(this).height())
			
			$(this).scrollspy
				min: position.top
				max: position.top + $(this).height()
				container: $("#bars")
				
				onEnter: (element, position) ->
					#console?.log "entering " + element.id[4...]
					#console?.log element
					#$("body").css "background-color", element.id
					BEATmatic.play.highlightScroll element.id[4...]
	
				#onLeave: (element, position) ->
				#	console?.log "leaving " + element.id
	#inBetween: (num, first, last) ->
	#	(first < last ? num >= first && num <= last : num >= last && num <= first)
	 
	highlightScroll: (col) =>
		#console.log "highlightScroll"+col
		#console.log "scoresMax"+@scoresMax
		for index in [1..@scoresMax]
			#console.log index
			#console.log "testing if #{index} is in between #{col} and #{col+9}: " + ( index >= col and index <= col+9)
			if index >= col and index <= Number(col)+@ticksOnScreen#@inBetween index, col, col+9
				#console.log "yea" +index
				$("#sbar"+index).addClass "high"
			else
				#console.log "not "+index
				$("#sbar"+index).removeClass "high"
	
	highlightTick: (col) ->
		@highCol.removeClass "high" if @highCol
		@highCol = $("#tick"+col)
		@highCol.addClass "high"
		
		#if (col % 4) is 0
		#	bar = col / 4
			
		@highOverview.removeClass "high" if @highOverview
		@highOverview = $("""#obar#{col}""")
		@highOverview.addClass "high"
		
	###	
	enableSwipe: =>	
		$("#hor-minimalist-a").swipe
			click: (e, target) =>
				score = e.target.cellIndex + 1
				track = e.target.parentNode.rowIndex
				
				cell = $($(".c#{score}")[track])
				if cell.hasClass "x100"
					cell.removeClass "x100"
					BEATmatic.drumPattern.tracks[track].score[score - 1] = 0
				else
					cell.addClass "x100"
					
					BEATmatic.drumPattern.tracks[track].score[score - 1] = 100
		
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
					sample = BEATmatic.drumPattern.tracks[track].sample
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
					BEATmatic.drumPattern.tracks[track].sample = newsample
					
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
	
