
class DiracPlayer
	constructor: (@voice) ->
		console.log "MPD: initializing Dirac player for voice: " + @voice

	play: (playEndedCallback) ->
		#console.log "MPD: called play: " + @voice
		Cordova.exec(playEndedCallback, playEndedCallback, "DiracPlayer", "play", [@voice])

	stop: ->
		#console.log "MPD: called stop: " + @voice
		Cordova.exec(@nop, @nop, "DiracPlayer", "stop", [@voice])

	changeDuration: (duration) ->
		console.log "MPD: called changeDuration: " + @voice
		Cordova.exec(@nop, @nop, "DiracPlayer", "changeDuration", [@voice, duration])

	changePitch: (pitch) ->
		console.log "MPD: called changePitch: " + @voice
		Cordova.exec(@nop, @nop, "DiracPlayer", "changePitch", [@voice, pitch])

	nop: ->
		# it's a noop.
	
class DiracPlayerMgr
	nop: ->
		# it's a noop.

	constructor: () ->
		console.log "MPD: creating dirac player manager."
		Cordova.exec(@nop, @nop, "DiracPlayer", "diracInit", [])

	newPlayer: (voice, sampleUrl) ->
		console.log "MPD: creating new dirac player for " + voice + " and " + sampleUrl
		result = new DiracPlayer(voice)
		Cordova.exec(@nop, @nop, "DiracPlayer", "load", [voice, sampleUrl])
		result

$ ->
	BEATmatic.DiracPlayerMgr = DiracPlayerMgr
	BEATmatic.DiracPlayer = DiracPlayer
