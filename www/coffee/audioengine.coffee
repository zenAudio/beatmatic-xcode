
class AudioEngine
	constructor: () ->
		console.log "MPD: JS: AudioEngine: initialising audio engine wrapper object"

	init: (drumMachinePreset, looperPreset) ->
		console.log "MPD: JS: AudioEngine: Initialising audio engine with presets #{drumMachinePreset}, and #{looperPreset}"
		Cordova.exec(@nop, @nop, "AudioEngine", "initialise", [drumMachinePreset, looperPreset])

	playTestTone: () ->
		console.log "MPD: JS: AudioEngine: playing test tone."
		Cordova.exec(@nop, @nop, "AudioEngine", "playTestTone", [])

	auditionDrum: (drumSound) ->
		console.log "MPD: JS: AudioEngine: auditioning drum #{drumSound}"
		Cordova.exec(@nop, @nop, "AudioEngine", "auditionDrum", [drumSound])

	setDrumPattern: (drumPattern) ->
		console.log "MPD: JS: AudioEngine: setting drum pattern to #{drumPattern}"
		Cordova.exec(@nop, @nop, "AudioEngine", "setDrumPattern", [drumPattern])

	toggleLoop: (group, ix) ->
		console.log "MPD: JS: AudioEngine: toggling loop #{group}, index #{ix}"
		Cordova.exec(@nop, @nop, "AudioEngine", "toggleLoop", [group, ix])

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

