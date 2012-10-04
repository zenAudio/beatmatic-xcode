class EventBase
	_callbacks: {}
	bind: (ev, callback) ->
		evs   = ev.split(' ')
		calls = @hasOwnProperty('_callbacks') and @_callbacks or= {}

		for name in evs
			calls[name] or= []
			calls[name].push(callback)
		this

	one: (ev, callback) ->
		@bind ev, ->
			@unbind(ev, arguments.callee)
			callback.apply(@, arguments)

	trigger: (args...) ->
		ev = args.shift()

		list = @hasOwnProperty('_callbacks') and @_callbacks?[ev]
		return unless list

		for callback in list
			if callback.apply(@, args) is false
				break
		true

	unbind: (ev, callback) ->
		unless ev
			@_callbacks = {}
			return this

		list = @_callbacks?[ev]
		return this unless list

		unless callback
			delete @_callbacks[ev]
			return this

		for cb, i in list when cb is callback
			list = list.slice()
			list.splice(i, 1)
			@_callbacks[ev] = list
			break
		this
		
class AudioEngine extends EventBase
	#bpm: 120
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
		#@bpm = bpm
		Cordova?.exec(@nop, @nop, "AudioEngine", "setBpm", [bpm])
		@trigger "bpm", bpm

	getBpm: () ->
		#console.log "MPD: JS: AudioEngine:getBpm"
		#@bpm
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
	#BEATmatic.audioEngine.bind "bpm", (bpm) ->
	#	console.log "bpm changed to #{bpm}"
