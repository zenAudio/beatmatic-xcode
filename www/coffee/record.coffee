class rec
	ready: false
	#url: "http://192.168.2.105:5000/"
	#url: "http://localhost:5000/"
	url: "http://ec2-46-51-129-29.eu-west-1.compute.amazonaws.com/?id="+device?.uuid
	
	constructor: ->
		window.document.addEventListener "deviceready", @deviceready, false
		@setup = true
		@ready = false
		
		#$("#toTable").click =>
		#	BEATmatic.play.setup("demo")
		#	BEATmatic.ui.switch("synth")
		
		$("#recordBtn").click =>
			@recordAudio3()
			
		$("#processingBtn").click =>
			@switchButtons "recordBtn"
			@mediaRec.stopRecord()
		
		$("#stopBtn").click =>
			@switchButtons "processingBtn"
			@mediaRec.stopRecord()
		
		#BEATmatic.rec.showMicLevel	

	switchButtons: (buttonToShow) ->
		for button in ["stopBtn", "processingBtn", "recordBtn"]
			if button is buttonToShow
				$("#"+button).show()
			else
				$("#"+button).hide()
	
	deviceready: =>
		#window.requestFileSystem LocalFileSystem.PERSISTENT, 0, @gotFS, @nothing
		#document.querySelector("#deviceready .pending").className += " hide"
		#completeElem = document.querySelector("#deviceready .complete")
		#completeElem.className = completeElem.className.split("hide").join("")
		
		console.log "deviceready"
		###
		BEATmatic.audioEngine.init("sounds/drummachine/defpreset/preset.json", "sounds/looper/defpreset/preset.json")
		
		BEATmatic.audioEngine.setAudioInputLevelCallback (level) =>
			console.log level
			@showMicLevel level
		###	
		BEATmatic.audioEngine.init "sounds/drummachine/defpreset/preset.json", "sounds/looper/defpreset/preset.json", =>
			BEATmatic.audioEngine.setCursorCallback (cursorPosJson) =>
				console.log "TFD:"+cursorPosJson
				time = JSON.parse(cursorPosJson)
				#$("#timeKeeper").text time.bars + "." + time.beats + "." + time.ticks

			BEATmatic.audioEngine.setAudioInputLevelCallback (level) =>
				#console.log "TFD:"+level
				#level = JSON.parse(level)
				#console.log level
				#$("#levelDisplay").text level
				@showMicLevel level

			console.log "MPD:HTML:onDeviceReady: initialized drum preset."
			#console.log "MPD:HTML:onDeviceReady: about to set drum pattern to " + json
			BEATmatic.audioEngine.applyDrumPattern()
			console.log "MPD:HTML:onDeviceReady:set drum pattern."
			
			BEATmatic.audioEngine.play()
		
	
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
	
	
	# Record audio
	# 
	
	gotFS: (fileSystem) =>
		console.log "got filesystem"
		@fileSystem = fileSystem
		@src = "test.wav"#@getFilePath() + "myrecording.wav"
		#console.log "trying to recording to #{@src}"
		@fileSystem.root.getFile(@src, {create: true}, @fileReady, @nothing)
		
	fileReady: (fileEntry) =>
		@recordFile = fileEntry

	
	nothing: ->
		#console.log "nothing"
		
	recordAudio3: (fileEntry) =>
		@switchButtons "stopBtn"
	
		#console.log fileEntry.fullPath
		#@recordFile = fileEntry
		@mediaRec = new Media(@recordFile.fullPath, @onSuccess, @onError)
		#console.log "recording to #{@src}"
		
		# Record audio
		@mediaRec.startRecord()
		###
		recTime = 0
		recInterval = setInterval(->
			recTime = recTime + 1
			setAudioPosition recTime + " sec"
			#if recTime >= 10
			#	clearInterval recInterval
			#	@mediaRec.stopRecord()
		, 1000)#http://localhost:5000/
		###
		
	
	# onSuccess Callback
	#
	onSuccess: =>
		#$("#stoprecord").hide()
		#$("#record").show()
		
		console.log "recordAudio():Audio Success"
		@uploadFile()
		
	uploadFile: =>
		console.log "starting upload"
		mediaFile = @recordFile
		ft = new FileTransfer()
		path = mediaFile.fullPath
		name = mediaFile.name
		ft.upload path, @url, @uploadSuccess, @uploadError, {fileName: name}
		
	uploadSuccess: =>
		data = decodeURIComponent result.response
		BEATmatic.play.setup(JSON.parse data)
		BEATmatic.ui.switch("synth2")
	uploadError: (error) =>
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
