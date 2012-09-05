
class DiracPlayer

	# This is basically like calling initWithContentsOfURL.
	constructor: (@url) ->
		console.log "MPD: initializing Dirac player with URL: " + @url

	prepare: (success, fail, resultType) ->
		console.log "MPD: in prepare: url: " + @url
		Cordova.exec(success, fail, "DiracPlayer", "load", [@url])

	play: (success, fail, resultType) ->
		console.log "MPD: called play."
		Cordova.exec(success, fail, "DiracPlayer", "play", [])

	stop: (success, fail, resultType) ->
		console.log "MPD: called stop."
		Cordova.exec(success, fail, "DiracPlayer", "stop", [])

	changeDuration: (duration, success, fail, resultType) ->
		console.log "MPD: called changeDuration."
		Cordova.exec(success, fail, "DiracPlayer", "changeDuration", [duration])

	changePitch: (pitch, success, fail, resultType) ->
		console.log "MPD: called changePitch."
		Cordova.exec(success, fail, "DiracPlayer", "changePitch", [pitch])

BEATmatic.player = DiracPlayer
