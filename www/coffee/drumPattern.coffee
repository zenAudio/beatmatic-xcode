class DrumPattern
	@bpm: 120
	@tracks: [
		name: "kick drum"
		score: [100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 100]
	,
		name: "snare drum"
		score: [0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0]
	,
		name: "hi-hat"
		score: [0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0]
	]
	
	getAsJSON: ->
		JSON.stringify {bpm: @bpm, tracks: @tracks}
	
	setDemoPattern: ->
		@bpm = 120
		@tracks = [
			name: "kick drum"
			score: [100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 100]
		,
			name: "snare drum"
			score: [0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0]
		,
			name: "hi-hat"
			score: [0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0]
		]
		
		BEATmatic.audioEngine.applyDrumPattern()

BEATmatic.drumPattern = new DrumPattern()