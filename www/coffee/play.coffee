class sequencer
	coreLoop: false
	BPM: 120
	beat16: 1
	beatTotal: 1
	record: false
	recording: {}
	highlightPlayer: false
	folder: "sounds/"
	drumTracksToPlay: [0, 1, 2]
	drumTracks: {}
	sampleTacksToPlay: []
	sampleTracks: {}
	
	#constructor: ->
				
	setup: (tracks) ->
		@drumTracks = tracks
		@BPM = @drumTracks.bpm
		@startCoreLoop()
		
	beat: ->
		#Play Drums
		for track in @drumTracksToPlay
			if @drumTracks.tracks[track].score[@beat16-1] >= 100
				@playAudio @folder + "drums/" + @drumTracks.tracks[track].sample
		
		samplesPlayed = []
			
		for track in @sampleTacksToPlay
			sample = @sampleTracks[track]
			samplesPlayed.push sample
			@playAdjustedAudio @folder + "samples/" + sample
		
		
		BEATmatic.play.highlightColumn @beat16 if @highlightPlayer
		
		if record
			recording[@beatTotal] =
				"beat16": @beat16
				"samples": samplesPlayed
				"BPM": @BPM
				"drums": @drumTracksToPlay
		
		@sampleTacksToPlay = {}	
	
	playAdjustedAudio: (src) ->
		@playAudio(src)
	
	playAudio: (src) ->
		if Media?
			my_media = new Media(src)#, @onSuccess, @onError, @onStatus)
			my_media.play()
		else
			#HTML5
			new Audio(src).play();
	
	changeBPM: (newBPM) ->
		@BPM = newBPM
		console.log "changed BPM to #{newBPM}"
		@stopCoreLoop()
		@startCoreLoop()
	
	startCoreLoop: ->
		ms = 15000 / @BPM
		ms = ms.toFixed(0)
		
		@coreLoop = setInterval(=>
			@beat()
			@beat16++
			@beatTotal++
			@beat16 = 1 if @beat16 is 17
		, ms)
	
	stopCoreLoop: ->
		clearInterval @coreLoop
		
		if @highlightPlayer
			$(".highlighted").removeClass "highlighted"

	onError: (error) ->
		alert "code: " + error.code + "\n" + "message: " + error.message + "\n"
	
	

		
	


$ ->
	BEATmatic.sequencer = new sequencer()






	
class play
	loopTimers: {}
	swipeSampleLayover: false
	swipeVolumeLayover: false
	
	lastSample: false
	originalbpm: false
	direction: false
	lastDistance: 0
	
	constructor: ->
		
		$("#snext").click =>
			#@stopLoop()
			BEATmatic.ui.switch("dj")
			BEATmatic.sequencer.highlightPlayer = false
			false
		
		$("sback").click =>
			#@stopLoop()
			BEATmatic.sequencer.stopCoreLoop()
			BEATmatic.ui.switch("main")
			BEATmatic.sequencer.highlightPlayer = false
			false
			
		@setup("demo")
		
		
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
	
	
	
	generateHTML: =>
		html = """<table id="hor-minimalist-a" class="fulltable" summary="Matrix">"""
		for track, index in BEATmatic.sequencer.drumTracks.tracks
			html += "<tr>"
			html += """<td class=""><img width="50" height="50" src="img/#{track.icon}" alt="#{track.name}"/></td>"""
			for score, index in track.score
				if score >= 100
					score = 100
				html += """<td class="x#{score} c#{index+1}"></td>"""
			html += "</tr>"
			
			
		html += "</table>"
		$("#matrix").html html
		
		
		$("#hor-minimalist-a").swipe
			click: (e, target) =>
				#console.log @data
				score = e.target.cellIndex
				track = e.target.parentNode.rowIndex
				#BEATmatic.sequencer.drumTracksToPlay TODO
				
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
					console.log "****END****"
					@direction = false
					@lastDistance = 0
					
					if @swipeSampleLayover
						$("#swipeSampleLayover").hide()
						@swipeSampleLayover = false
						@stopLoop()
						@loopTracks()
						
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
						#console.log "*** Show Samples"
						#console.log "*** Show Samples!!!"
						@stopLoop()
						@swipeSampleLayover = true
						###

						if e.pageX
							x = e.pageX
						else
							x = e.touches[0].pageX
						
						if e.pageY
							y = e.pageY
						else
							y = e.touches[0].pageY	
						
						totalHeight = $("body").height()
						layoverHeight = $("#swipeSampleLayover").height()
						offset = 0
						
						
						if y < layoverHeight/2
							#console.log "<"
							offset = layoverHeight/2 - y
							#x = layoverHeight/2
						
						#console.log "totalHeight - y < layoverHeight/2 : #{totalHeight - y} < #{layoverHeight/2} #{totalHeight - y < layoverHeight/2}"
						
						if totalHeight - y < layoverHeight/2
							#console.log ">"
							offset = totalHeight - y - layoverHeight/2
						
						
						#console.log offset
						$("#swipeSampleLayover").css "top", y + offset - layoverHeight/2
						#console.log e.touches
						#console.log e
						$("#swipeSampleLayover").css "left", x - 10
						#$("#swipeSampleLayover").css "left", 15
						###
						$("#swipeSampleLayover").show()
						@samplebase = false
						
					
					
					#have at least 5px differnece from last time
					
					move =  distance - @lastDistance
					console.log "***"
					console.log distance
					console.log @lastDistance
					console.log move
					console.log "***"
					
					
					#mouse move above 10px or below -10
					if (move < 10) and (move > -10)
						console.log "did not move enough"
						console.log move
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
					@playAudio @folder + newsample
					BEATmatic.sequencer.drumTracks.tracks[track].sample = newsample
					
					$("#swipeSampleLayover").html(newsample)
					#alert i = test.indexOf "0"
					
					#test[...i] + test[i+2...]
					
					#volume
					
						
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
					#@stopLoop()
					#@loopTracks()
					
				
				return
				
				#$(this).html "You swiped " + swipeCount + " times"
			allowPageScroll: "none"
			threshold: 50
		
		###
		
		$("#hor-minimalist-a").click (e) =>
			#console.log e
			#console.log e.target.parentNode.rowIndex
			#console.log e.target.cellIndex
			
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
			
	
	highlightColumn: (col) ->
		$(".c#{col}").addClass "highlighted"
		col = col - 1
		col = 16 if col is 0
		$(".c#{col}").removeClass "highlighted"
			

$ ->
	BEATmatic.play = new play()