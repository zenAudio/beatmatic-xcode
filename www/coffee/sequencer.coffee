class sequencer
	coreLoop: false
	BPM: 120
	beat16: 1
	beatTotal: 1
	recording: false
	recordObject: {}
	highlightPlayer: false
	folder: "sounds/"
	drumTracksToPlay: [0, 1, 2]
	drumTracks: {}
	sampleTacksToPlay: []
	sampleTracks: {}
	sampleTacksPlaying: {}
				
	setup: (tracks) ->
		@drumTracks = tracks
		@drumTracksToPlay = [0, 1, 2]
		@recording = false
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
		
		if @recording
			@recordObject[@beatTotal] =
				"beat16": @beat16
				"samples": samplesPlayed
				"BPM": @BPM
				"drums": @drumTracksToPlay
		
		@sampleTacksToPlay = []
		
	playAdjustedAudio: (sample, src) ->
		src = @folder + "samples/" + src
		#console.log "playAdjustedAudio #{sample}, #{src}"
		if Cordova?
			@sampleTacksPlaying[sample] = player = new BEATmatic.DiracPlayer(sample, src)
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
		@pauseCoreLoop()
		
		#stretchSamples
		for samplePlaying, player of @sampleTacksPlaying
			player.changeDuration 120 / @BPM, nop, nop, nop
			
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
	
	pauseCoreLoop: ->
		clearInterval @coreLoop
	
	stopCoreLoop: ->
		clearInterval @coreLoop
		
		if @highlightPlayer
			$(".highlighted").removeClass "highlighted"
		
		for samplePlaying, player of @sampleTacksPlaying
			player.stop()
		
		@sampleTacksPlaying = {}

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
		@sampleTacksToPlay.push sample
	
	stopSample: (sample) =>
		i = $.inArray(sample, BEATmatic.sequencer.sampleTacksToPlay)
		unless i is -1
			@sampleTacksToPlay.splice i, 1

		for samplePlaying, player of @sampleTacksPlaying
			if samplePlaying is sample
				player.stop()
				delete @sampleTacksPlaying[samplePlaying]

	record: ->
		#Find the right time to start recording, reset the bars
		#@beatTotal = 1
		#@beat16 = 1
		@recording = true


$ ->
	BEATmatic.sequencer = new sequencer()