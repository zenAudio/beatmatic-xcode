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
			BEATmatic.drumPattern.setDemoPattern()
			BEATmatic.ui.switch "synth"
			
		#@showMicLevel 50
			

	switchButtons: (buttonToShow) ->
		for button in ["stopBtn", "processingBtn", "recordBtn"]
			if button is buttonToShow
				$("#"+button).show()
			else
				$("#"+button).hide()
	
	deviceready: =>
		@deviceready = true
		window.requestFileSystem LocalFileSystem.PERSISTENT, 0, @gotFS, @nothing
		#document.querySelector("#deviceready .pending").className += " hide"
		#completeElem = document.querySelector("#deviceready .complete")
		#completeElem.className = completeElem.className.split("hide").join("")
		
		#console.log "deviceready"

		BEATmatic.audioEngine.init "sounds/drummachine/defpreset/preset.json", "sounds/loopmachine/betapak/preset.json", =>
			BEATmatic.audioEngine.setAudioInputLevelCallback (level) =>
				@showMicLevel level

			BEATmatic.audioEngine.applyDrumPattern()
				
	startLevelMeter: =>
		if @deviceready
			BEATmatic.audioEngine.setAudioInputLevelCallback (level) =>
				@showMicLevel level
	
	stopLevelMeter: =>
		BEATmatic.audioEngine.setAudioInputLevelCallback false
	
	showMicLevel: (percent) ->
		#level = 100 - percent
		percent = percent + 10 unless percent is 0
		#$("#recordLevel").css("background", "-webkit-linear-gradient(top, rgba(255,255,255,1) 0%,rgba(255,255,255,1) #{level}%,rgba(255,0,0,1) 100%)")#rgba(167,250,248,1)
		$("#recordLevel").css("background", "-webkit-linear-gradient(bottom, rgba(255,255,255,1) 0%,rgba(255,255,255,0) 0%,rgba(255,255,255,1) #{percent}%)")
		percent
		
		
	getFilePath: ->
		#if detectAndroid()
		if device.platform is "Android"
			return "file:///android_asset/www/res/db/"
		else
			return "res//db//"
	
	gotFS: (fileSystem) =>
		@fileSystem = fileSystem
		@src = "test.ogg"#@getFilePath() + "myrecording.wav"
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
		#console.log "uploadSuccess"
		#console.log result
		data = decodeURIComponent result.response
		console.log "SERVER RESPONSE"
		#console.log data
		resultData = JSON.parse data
		console.log resultData
		
		
		BEATmatic.drumPattern.bpm = resultData.bpm
		#console.log "DP before"
		#console.log BEATmatic.drumPattern.tracks
		
		#console.log "setting it to"
		#console.log resultData.tracks
		
		BEATmatic.drumPattern.tracks = resultData.tracks
		#console.log "DP after"
		#console.log BEATmatic.drumPattern.tracks
		BEATmatic.audioEngine.applyDrumPattern()
				
		BEATmatic.ui.switch "synth"
		
		
	uploadError: (error) =>
		console.log "uploadError"
		@switchButtons "recordBtn"
		console.log error
		alert "Error uploading file to get processed. No Network?"
		
		
	onError: (error) ->
		alert "code: " + error.code + "\n" + "message: " + error.message + "\n"
	
	
	setAudioPosition: (position) ->
		document.getElementById("audio_position").innerHTML = position

$ ->
	BEATmatic.rec = new rec()
