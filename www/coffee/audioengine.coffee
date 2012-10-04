
class AudioEngine
	###
	drumPattern:
		bpm: 120
		tracks: [
			name: "kick drum"
			score: [100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 100]
		,
			name: "snare drum"
			score: [0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0]
		,
			name: "hi-hat"
			score: [0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0]
		]
	###
	
	
	constructor: () ->
		#console.log "MPD: JS: AudioEngine: initialising audio engine wrapper object"

	init: (drumMachinePreset, looperPreset, callbackFn) ->
		#console.log "MPD: JS: AudioEngine: Initialising audio engine with presets #{drumMachinePreset}, and #{looperPreset}"
		Cordova?.exec(callbackFn, callbackFn, "AudioEngine", "initialise", [drumMachinePreset, looperPreset])

	playTestTone: () ->
		console.log "MPD: JS: AudioEngine: playing test tone."
		Cordova?.exec(@nop, @nop, "AudioEngine", "playTestTone", [])

	auditionDrum: (drumSound) ->
		#console.log "MPD: JS: AudioEngine: auditioning drum #{drumSound}"
		Cordova?.exec(@nop, @nop, "AudioEngine", "auditionDrum", [drumSound])

	applyDrumPattern: () ->
		#console.log "MPD: JS: AudioEngine: setting drum pattern to #{BEATmatic.drumPattern.getAsJSON()}"
		#console.log json1 = JSON.stringify @drumPattern
		#console.log json2 = BEATmatic.drumPattern.getAsJSON()
		Cordova?.exec(@nop, @nop, "AudioEngine", "setDrumPattern", [BEATmatic.drumPattern.getAsJSON()])

	toggleLoop: (group, ix) ->
		#console.log "MPD: JS: AudioEngine: toggling loop #{group}, index #{ix}"
		Cordova?.exec(@nop, @nop, "AudioEngine", "toggleLoop", [group, ix])

	play: () ->
		#console.log "MPD: JS: AudioEngine:play"
		Cordova?.exec(@nop, @nop, "AudioEngine", "play", [])

	playSample: (filename, finishedPlayingCb) ->
		#console.log "MPD: JS: AudioEngine:playSample"
		Cordova?.exec(finishedPlayingCb, finishedPlayingCb, "AudioEngine", "playSample", [filename])

	stopSample: (filename) ->
		#console.log "MPD: JS: AudioEngine:stopSample"
		Cordova?.exec(@nop, @nop, "AudioEngine", "stopSample", [])

	setBpm: (bpm) ->
		#console.log "MPD: JS: AudioEngine:setBpm"
		Cordova?.exec(@nop, @nop, "AudioEngine", "setBpm", [bpm])

	getBpm: () ->
		#console.log "MPD: JS: AudioEngine:getBpm"
		if Cordova?
			return Cordova.exec(@nop, @nop, "AudioEngine", "getBpm", [])
		else
			return 120

	stop: () ->
		#console.log "MPD: JS: AudioEngine:stop"
		Cordova?.exec(@nop, @nop, "AudioEngine", "stop", [])

	setCursorCallback: (callbackFn) ->
		#console.log "MPD: JS: AudioEngine:setCursorCallback"
		if callbackFn == false
			Cordova?.exec(@nop, @nop, "AudioEngine", "turnOffCursorCallback", [])
		else
			Cordova?.exec(callbackFn, callbackFn, "AudioEngine", "setCursorCallback", [])

	setAudioInputLevelCallback: (callbackFn) ->
		#console.log "MPD: JS: AudioEngine:setAudioInputLevelCallback"
		if callbackFn == false
			Cordova?.exec(@nop, @nop, "AudioEngine", "turnOffAudioInputLevelCallback", [])
		else
			Cordova?.exec(callbackFn, callbackFn, "AudioEngine", "setAudioInputLevelCallback", [])

	setOneShotFinishedPlayingCallback: (groupName, loopIx, callbackFn) ->
		Cordova?.exec(callbackFn, callbackFn, "AudioEngine", "setOneShotFinishedPlayingCallback", [groupName, loopIx])

	recordAudioStart: (filename) ->
		#console.log "MPD: JS: AudioEngine:recordAudioStart"
		Cordova?.exec(@nop, @nop, "AudioEngine", "recordAudioStart", [filename])

	recordAudioStop: (recordFinishedCb) ->
		#console.log "MPD: JS: AudioEngine:recordAudioStop"
		Cordova?.exec(recordFinishedCb, recordFinishedCb, "AudioEngine", "recordAudioStop", [])

	setMasterFilter: (filterParams) ->
		#console.log "MPD: JS: AudioEngine:setMasterFilter: #{filterParams}"
		if filterParams is false or filterParams is true
			v = 0
			if filterParams is true
				v = 1
			Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterFilterEnabled", [v])
		else
			Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterFilter", [JSON.stringify(filterParams)])
	
	setMasterVerb: (params) ->
		#console.log "MPD: JS: AudioEngine:setMasterFilter"
		Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterVerb", [JSON.stringify(params)])

	setMasterCrusher: (params) ->
		#console.log "MPD: JS: AudioEngine:setMasterCrusher: #{params}"
		if params is false or params is true
			v = 0
			if params is true
				v = 1
			Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterCrusherEnabled", [v])
		else
			Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterCrusher", [JSON.stringify(params)])

	nop: () ->
		# no op

$ ->
	BEATmatic.audioEngine = new AudioEngine()
