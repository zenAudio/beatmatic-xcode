class rec
	ready: false
	#url: "http://192.168.2.105:5000/"
	#url: "http://localhost:5000/"
	url: "http://ec2-46-51-129-29.eu-west-1.compute.amazonaws.com/?id="+device?.uuid
	
	constructor: ->
		window.document.addEventListener "deviceready", @deviceready, false
		@setup = true
		@ready = false
		
		$("#recordBtn").click =>
			@recordAudio3()
			
		$("#processingBtn").click =>
			@switchButtons "recordBtn"
			BEATmatic.audioEngine.recordAudioStop (response) ->
				console.log "recordAudioStop - discarding"
				#$("#playAudioBtn").button "enable"
			#@mediaRec.stopRecord()
		
		$("#stopBtn").click =>
			@switchButtons "processingBtn"
			BEATmatic.audioEngine.recordAudioStop (response) ->
				console.log "recordAudioStop - uploading"
				BEATmatic.rec.uploadFile()
				
		$("#demoBtn").click =>	
			BEATmatic.play.setup2()
			BEATmatic.ui.switch "synth2"
			BEATmatic.audioEngine.play()
			

	switchButtons: (buttonToShow) ->
		for button in ["stopBtn", "processingBtn", "recordBtn"]
			if button is buttonToShow
				$("#"+button).show()
			else
				$("#"+button).hide()
	
	deviceready: =>
		window.requestFileSystem LocalFileSystem.PERSISTENT, 0, @gotFS, @nothing
		#document.querySelector("#deviceready .pending").className += " hide"
		#completeElem = document.querySelector("#deviceready .complete")
		#completeElem.className = completeElem.className.split("hide").join("")
		
		#console.log "deviceready"

		BEATmatic.audioEngine.init "sounds/drummachine/defpreset/preset.json", "sounds/looper/defpreset/preset.json", =>
			BEATmatic.audioEngine.setCursorCallback (cursorPosJson) =>
				console.log "TFD:"+cursorPosJson
				time = JSON.parse(cursorPosJson)
				#{"bars": 6, "beats": 4, "ticks": 2}
				console.log "ticks: #{(time.beats - 1 )* 4 + time.ticks}"
				BEATmatic.play.highlightTick (time.beats - 1 ) * 4 + time.ticks
				#$("#timeKeeper").text time.bars + "." + time.beats + "." + time.ticks

			BEATmatic.audioEngine.setAudioInputLevelCallback (level) =>
				@showMicLevel level

			console.log "MPD:HTML:onDeviceReady: initialized drum preset."
			#console.log "MPD:HTML:onDeviceReady: about to set drum pattern to " + json
			BEATmatic.audioEngine.applyDrumPattern()
			console.log "MPD:HTML:onDeviceReady:set drum pattern."
			
			#BEATmatic.audioEngine.play()
		
	
	showMicLevel: (percent) ->
		level = 100 - percent
		$("#recordLevel").css("background", "-webkit-linear-gradient(top, rgba(255,255,255,1) 0%,rgba(255,255,255,1) #{level}%,rgba(255,0,0,1) 100%)")#rgba(167,250,248,1)
		level
		
		
	getFilePath: ->
		#if detectAndroid()
		if device.platform is "Android"
			return "file:///android_asset/www/res/db/"
		else
			return "res//db//"
	
	gotFS: (fileSystem) =>
		@fileSystem = fileSystem
		@src = "test.wav"#@getFilePath() + "myrecording.wav"
		@fileSystem.root.getFile(@src, {create: true}, @fileReady, @nothing)
		
	fileReady: (fileEntry) =>
		@recordFile = fileEntry

	
	nothing: ->
		#console.log "nothing"
		
	recordAudio3: (fileEntry) =>
		@switchButtons "stopBtn"		
		BEATmatic.audioEngine.recordAudioStart @recordFile.fullPath

	uploadFile: =>
		ft = new FileTransfer()
		ft.upload @recordFile.fullPath, @url, @uploadSuccess, @uploadError, {fileName: @recordFile.name}
		
	uploadSuccess: (result) =>
		console.log "uploadSuccess"
		console.log result
		data = decodeURIComponent result.response
		console.log "SERVER RESPONSE"
		console.log data
		resultData = JSON.parse data
		console.log resultData
		
		#drumData = 
		#	bpm: resultData.bpm
		#	tracks: resultData.tracks
		
		BEATmatic.drumPattern.bpm = resultData.bpm
		BEATmatic.drumPattern.tacks = resultData.tracks
		BEATmatic.audioEngine.applyDrumPattern()
		
		###
		BEATmatic.audioEngine.drumPattern =
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
		{"project":"Untitled beat","bpm":273,"tracks":[{"name":"kick drum","sample":"kick01.wav","icon":"kickdrum.png","score":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},{"name":"snare drum","sample":"snare01.wav","icon":"snaredrum.png","score":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},{"name":"hi-hat","sample":"hihat01.wav","icon":"hihat.png","score":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}]}
		###
		
		
		BEATmatic.ui.switch("synth2")
		BEATmatic.audioEngine.play()
		
	uploadError: (error) =>
		console.log "uploadError"
		@switchButtons "recordBtn"
		console.log error
		alert "Error uploading file to get processed. No Network?"
		
	# onError Callback 
	#
	onError: (error) ->
		alert "code: " + error.code + "\n" + "message: " + error.message + "\n"
	
	# Set audio position
	# 
	setAudioPosition: (position) ->
		document.getElementById("audio_position").innerHTML = position

#window.BEATmatic = {}
$ ->
	BEATmatic.rec = new rec()
