class sequencer
	drums: {BD: {name: "BD"}, SD: {name: "SD"}}
		BaseDrum:
			xxx
		Snare:
			
		KickDrum:
		
	instruments:
		Baseline:
			A:
			B:
			C:
			D:
	
	FX:
		FilterSweep
		VocStop
		Stutter
		TapeStop
		
	
	#		
	
	#getVoice: (name) ->
	#	return voice
		
	playLoop: (instrument, variation) ->
		return
		
	stopLoop: (instrument) ->
		return
	
		
	setDrumPattern: (drumname, sequence = [100, 0, 100]) ->
		return drumname
	
	setDrumSample: (drumname, WAV) ->
		
	
	playDrumPattern: (voicename) ->
		return
		
	stopDrumPattern: (voicename) ->
		return
			
	play: ->
		return
		
	record: ->
		return
	
	stop: ->
		return "the recording as wav?"
		
	auditionDrumSample: ->
		return
		
	playFX: (FX) ->
		return
	
	stopFX: (FX) ->
		return
	
	
	###
	optional
	###
	
	playChorus: (chorus) ->
		return
	
	
	recordChorus: (updateCountCallback) ->
		return
		
		#updateCountCallback -> values: 3, 2, 1, rec
		
	#getBeats: ->


