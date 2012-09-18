
class AudioEngine
	constructor: () ->
		console.log "MPD: JS: AudioEngine: initialising audio engine wrapper object"

	init: (drumMachinePreset, looperPreset, callbackFn) ->
		console.log "MPD: JS: AudioEngine: Initialising audio engine with presets #{drumMachinePreset}, and #{looperPreset}"
		Cordova?.exec(callbackFn, callbackFn, "AudioEngine", "initialise", [drumMachinePreset, looperPreset])

	playTestTone: () ->
		console.log "MPD: JS: AudioEngine: playing test tone."
		Cordova?.exec(@nop, @nop, "AudioEngine", "playTestTone", [])

	auditionDrum: (drumSound) ->
		console.log "MPD: JS: AudioEngine: auditioning drum #{drumSound}"
		Cordova?.exec(@nop, @nop, "AudioEngine", "auditionDrum", [drumSound])

	setDrumPattern: (drumPattern) ->
		console.log "MPD: JS: AudioEngine: setting drum pattern to #{drumPattern}"
		Cordova?.exec(@nop, @nop, "AudioEngine", "setDrumPattern", [drumPattern])

	toggleLoop: (group, ix) ->
		console.log "MPD: JS: AudioEngine: toggling loop #{group}, index #{ix}"
		Cordova?.exec(@nop, @nop, "AudioEngine", "toggleLoop", [group, ix])

	play: () ->
		console.log "MPD: JS: AudioEngine:play"
		Cordova?.exec(@nop, @nop, "AudioEngine", "play", [])

	playSample: (filename, finishedPlayingCb) ->
		console.log "MPD: JS: AudioEngine:playSample"
		Cordova?.exec(finishedPlayingCb, finishedPlayingCb, "AudioEngine", "playSample", [filename])

	stopSample: (filename) ->
		console.log "MPD: JS: AudioEngine:stopSample"
		Cordova?.exec(@nop, @nop, "AudioEngine", "stopSample", [])

	setBpm: (bpm) ->
		console.log "MPD: JS: AudioEngine:setBpm"
		Cordova?.exec(@nop, @nop, "AudioEngine", "setBpm", [bpm])

	getBpm: () ->
		console.log "MPD: JS: AudioEngine:getBpm"
		Cordova?.exec(@nop, @nop, "AudioEngine", "getBpm", [])

	stop: () ->
		console.log "MPD: JS: AudioEngine:stop"
		Cordova?.exec(@nop, @nop, "AudioEngine", "stop", [])

	setCursorCallback: (callbackFn) ->
		console.log "MPD: JS: AudioEngine:setCursorCallback"
		Cordova?.exec(callbackFn, callbackFn, "AudioEngine", "setCursorCallback", [])

	setAudioInputLevelCallback: (callbackFn) ->
		console.log "MPD: JS: AudioEngine:setAudioInputLevelCallback"
		Cordova?.exec(callbackFn, callbackFn, "AudioEngine", "setAudioInputLevelCallback", [])

	recordAudioStart: (filename) ->
		console.log "MPD: JS: AudioEngine:recordAudioStart"
		Cordova?.exec(@nop, @nop, "AudioEngine", "recordAudioStart", [filename])

	recordAudioStop: (recordFinishedCb) ->
		console.log "MPD: JS: AudioEngine:recordAudioStop"
		Cordova?.exec(recordFinishedCb, recordFinishedCb, "AudioEngine", "recordAudioStop", [])

	setMasterFilter: (filterParams) ->
		console.log "MPD: JS: AudioEngine:setMasterFilter"
		Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterFilter", [JSON.stringify(filterParams)])

	setMasterVerb: (params) ->
		console.log "MPD: JS: AudioEngine:setMasterFilter"
		Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterVerb", [JSON.stringify(params)])

	setMasterCrusher: (params) ->
		console.log "MPD: JS: AudioEngine:setMasterCrusher"
		Cordova?.exec(@nop, @nop, "AudioEngine", "setMasterCrusher", [JSON.stringify(params)])

	nop: () ->
		# no op

$ ->
	BEATmatic.audioEngine = new AudioEngine()

