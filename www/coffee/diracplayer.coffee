class DiracPlayer
    sampleName: false
	# This is basically like calling initWithContentsOfURL.
	constructor: () ->
		console.log "MPD: initializing Dirac player with URL: " + @url
		

	prepare: (sampleName, url) ->
		#console.log "MPD: in prepare: url: " + @url
		@sampleName = sampleName
		Cordova.exec(success, fail, "DiracPlayer", "load", [sampleName, url])

	play: ->
		#console.log "MPD: called play."
		Cordova.exec(@nothing, @nothing, "DiracPlayer", "play", [@sampleName])

	stop: ->
		#console.log "MPD: called stop."
		Cordova.exec(@nothing, @nothing, "DiracPlayer", "stop", [@sampleName])

    changeDuration: (duration) ->
		#console.log "MPD: called changeDuration."
		Cordova.exec(@nothing, @nothing, "DiracPlayer", "changeDuration", [@sampleName, duration])

	changePitch: (pitch) ->
		#console.log "MPD: called changePitch."
		Cordova.exec(@nothing, @nothing, "DiracPlayer", "changePitch", [@sampleName, pitch])
	
	nothing: ->
		#console.log "xxx"

#BEATmatic.player = DiracPlayerMgr
$ ->
	Cordova.exec(success, fail, "DiracPlayer", "init", []);
	BEATmatic.DiracPlayer = DiracPlayer