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
	sampleTracks: 
		baseline: 
			wav: "Synth_5.wav"
			callbacks: []
			loop: true
		percussion: 
			wav: "Percussion_2.wav"
			callbacks: []
			loop: true
		synth: 
			wav: "Synth_12.wav"
			callbacks: []
			loop: true
		melodic: 
			wav: "Melodic_5.wav"
			callbacks: []
			loop: true
			
	sampleTacksPlaying: {}
				
	setup: (tracks) ->
		console.log("MPD: SETTING UP SEQUENCER!")
		@drumTracks = tracks
		@drumTracksToPlay = [0, 1, 2]
		@recording = false
		@BPM = @drumTracks.bpm
		@startCoreLoop()
		@diracMgr = new BEATmatic.DiracPlayerMgr
		
	beat: ->
		#Play Drums
		for track in @drumTracksToPlay
			if @drumTracks.tracks[track].score[@beat16-1] >= 100
				@playAudio @folder + "drums/" + @drumTracks.tracks[track].sample
		
		samplesPlayed = []
			
		for track in @sampleTacksToPlay
			sample = @sampleTracks[track]
			
			samplesPlayed.push sample
			@playAdjustedAudio track, sample.wav, sample.loop, sample.callbacks
		
		
		BEATmatic.play.highlightColumn @beat16 if @highlightPlayer
		
		if @recording
			@recordObject[@beatTotal] =
				"beat16": @beat16
				"samples": samplesPlayed
				"BPM": @BPM
				"drums": @drumTracksToPlay
		
		@sampleTacksToPlay = []
	
	calcOffsetForPlaying: ->
		nextBeat = @beat16+1
		nextForth = Math.ceil(nextBeat / 4) * 4
		return (nextBeat - nextForth) * (15000 / @BPM)
			
		
	playAdjustedAudio: (sample, src, shouldLoop, callbacks) ->
		fname = src
		src = @folder + "samples/" + fname
		console.log "playAdjustedAudio #{sample}, #{src}"
		if Cordova?
			
			@sampleTacksPlaying[sample] = player = @diracMgr.newPlayer(sample, src)

			player.matchBPM @BPM
			player.play @calcOffsetForPlaying, =>
				for callback in callbacks
					callback(sample, src, player)
					if shouldLoop
						@sampleTacksToPlay.push sample
					
			player
		else
			@playAudio src
		
	playAudio: (src) ->
		if Media?
			my_media = new Media(src)#, @onSuccess, @onError, @onStatus)
			my_media.play()
		else
			#HTML5
			new Audio(src).play()
	
	changeBPM: (newBPM) ->
		@BPM = newBPM
		console.log "changed BPM to #{newBPM}"
		@pauseCoreLoop()
		
		#stretchSamples
		for samplePlaying, player of @sampleTacksPlaying
			player.matchBPM @BPM
			
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
		
	playSample: (sample, callback = false) =>
		@sampleTacksToPlay.push sample
		
		if callback
			@sampleTracks[sample].callbacks.push callback

	
	stopSample: (sample) =>
		i = $.inArray(sample, BEATmatic.sequencer.sampleTacksToPlay)
		unless i is -1
			@sampleTacksToPlay.splice i, 1

		for samplePlaying, player of @sampleTacksPlaying
			if samplePlaying is sample
				player.stop()
				delete @sampleTacksPlaying[samplePlaying]
				@sampleTracks[samplePlaying].callbacks = []

	record: ->
		#Find the right time to start recording, reset the bars
		#@beatTotal = 1
		#@beat16 = 1
		@recording = true


$ ->
	BEATmatic.sequencer = new sequencer()
