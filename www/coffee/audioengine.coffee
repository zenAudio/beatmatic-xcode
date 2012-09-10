
class AudioEngine
	constructor: () ->
		console.log "MPD: JS: AudioEngine: initialising audio engine wrapper object"

	init: (drumPreset) ->
		console.log "MPD: JS: AudioEngine: Initialising audio engine with preset file #{drumPreset}"
		Cordova.exec(@nop, @nop, "AudioEngine", "initialise", [drumPreset])

	playTestTone: () ->
		console.log "MPD: JS: AudioEngine: playing test tone."
		Cordova.exec(@nop, @nop, "AudioEngine", "playTestTone", [])

	auditionDrum: (drumSound) ->
		console.log "MPD: JS: AudioEngine: auditioning drum #{drumSound}"
		Cordova.exec(@nop, @nop, "AudioEngine", "auditionDrum", [drumSound])

	setDrumPattern: (drumPattern) ->
		console.log "MPD: JS: AudioEngine: setting drum pattern to #{drumPattern}"
		Cordova.exec(@nop, @nop, "AudioEngine", "setDrumPattern", [drumPattern])

	play: () ->
		console.log "MPD: JS: AudioEngine:play"
		Cordova.exec(@nop, @nop, "AudioEngine", "play", [])

	stop: () ->
		console.log "MPD: JS: AudioEngine:stop"
		Cordova.exec(@nop, @nop, "AudioEngine", "stop", [])

	setCursorCallback: (callbackFn) ->
		console.log "MPD: JS: AudioEngine:setCursorCallback"
		Cordova.exec(callbackFn, callbackFn, "AudioEngine", "setCursorCallback", [])

	nop: () ->
		# no op

$ ->
	BEATmatic.audioEngine = new AudioEngine()

