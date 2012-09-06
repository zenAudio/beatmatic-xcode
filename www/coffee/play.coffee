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
	sampleTacksPlaying: {}
	
	#constructor: ->
				
	setup: (tracks) ->
		@drumTracks = tracks
		@drumTracksToPlay = [0, 1, 2]
		@record = false
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
			@playAdjustedAudio track, sample
		
		
		BEATmatic.play.highlightColumn @beat16 if @highlightPlayer
		
		if record
			recording[@beatTotal] =
				"beat16": @beat16
				"samples": samplesPlayed
				"BPM": @BPM
				"drums": @drumTracksToPlay
		
		@sampleTacksToPlay = []
		
	playAdjustedAudio: (sample, src) ->
		src = @folder + "samples/" + src
		#console.log "playAdjustedAudio #{sample}, #{src}"
		if Cordova?
			@sampleTacksPlaying[sample] = player = new BEATmatic.DiracPlayer(src)
			console.log player
			nop = ->
				console.log "nothing"
			
			player.prepare(nop, nop, nop);
			#player.changePitch(5, nop, nop, nop);
			player.changeDuration 120 / @BPM, nop, nop, nop unless @BPM is 120
			player.play(nop, nop, nop)
			player
		else
			@playAudio src
		
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
		
	
	unMuteDrum: (drumNumber) =>
		if $.inArray(drumNumber, BEATmatic.sequencer.drumTracksToPlay) is -1
			BEATmatic.sequencer.drumTracksToPlay.push drumNumber
	
	muteDrum: (drumNumber) =>
		i = $.inArray(drumNumber, BEATmatic.sequencer.drumTracksToPlay)
		return  if i is -1
		BEATmatic.sequencer.drumTracksToPlay.splice i, 1
		
	playSample: (sample) =>
		console.log "adding sample #{sample}"
		@sampleTacksToPlay.push sample
		#@sampleTacksPlaying[sample]
	
	stopSample: (sample) =>
		i = $.inArray(sample, BEATmatic.sequencer.sampleTacksToPlay)
		unless i is -1
			@sampleTacksToPlay.splice i, 1
		
		
		#if @sampleTacksPlaying[samplePlaying]?
		#	@sampleTacksPlaying[samplePlaying].stop()
		#	delete @sampleTacksPlaying[samplePlaying]
		#return	
		
		#console.log @sampleTacksPlaying
		for samplePlaying, player of @sampleTacksPlaying
			if samplePlaying is sample
				player.stop()
				delete @sampleTacksPlaying[samplePlaying]
				#player = null
		#stop
		#@sampleTacksPlaying[sample]
		
	
	

		
	


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
		
		$("#sback").click =>
			#@stopLoop()
			BEATmatic.sequencer.stopCoreLoop()
			BEATmatic.ui.switch("main")
			BEATmatic.sequencer.highlightPlayer = false
			false
			
		#@setup("demo")
		
		
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
				score = e.target.cellIndex
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
		

			
	
	highlightColumn: (col) ->
		$(".c#{col}").addClass "highlighted"
		col = col - 1
		col = 16 if col is 0
		$(".c#{col}").removeClass "highlighted"
			

$ ->
	BEATmatic.play = new play()