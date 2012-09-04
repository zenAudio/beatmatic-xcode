class app
	ready: false
	url: "http://192.168.2.105:5000/"#"http://localhost:5000/"
	
	constructor: ->
		window.document.addEventListener "deviceready", @deviceready, false
		@setup = true
		@ready = false

		
		toTable
		
		$("#toTable").click =>
			window.localStorage.setItem "recordResults", "demo"
			window.location.href = 'table.html';
		
		$("#tester").click =>
		
			#dataDir = @fileSystem.root.getDirectory("www", {create: true}).getDirectory("sounds", {create: true})
			#console.log dataDir
			console.log "tester"
			my_media = new Media("sounds/tester.wav", nothing, nothing);
			
			#dataDir.getFile "tester.wav", {create: true}, (mediaFile) ->
			console.log "starting upload"
			console.log my_media
			#mediaFile = @recordFile
			ft = new FileTransfer()
			path = my_media.fullPath
			name = my_media.name
			ft.upload path, @url, ((result) ->
				data = decodeURIComponent result.response
				window.localStorage.setItem "recordResults", data
				window.location.href = 'table.html';
				
			), ((error) ->
				console.log "Error uploading file " + path + ": " + error.code
			),
				fileName: name
					
		
		$("#record").click =>
			#console.log "record click2"
			@recordAudio3()
			#@recordSound()
			
		$("#processingrecord").click =>
			$("#stoprecord").hide()
			$("#processingrecord").hide()
			$("#record").show()
			@mediaRec.stopRecord()
		
		$("#stoprecord").click =>
			console.log "stoprecord click"
			$("#stoprecord").hide()
			$("#processingrecord").show()
			$("#record").hide()
			@mediaRec.stopRecord()
			#@recordSound()	
		

	#bind: ->
	#	document.addEventListener "deviceready", @deviceready, false

	deviceready: =>
		console.log "device is ready!!!"
		window.requestFileSystem LocalFileSystem.PERSISTENT, 0, @gotFS, @nothing
		@ready = true
		# note that this is an event handler so the scope is that of the event
		# so we need to call app.report(), and not this.report()
		@report "deviceready"
		#@setupFile

	report: (id) ->
		console.log "report:" + id
		
		# hide the .pending <p> and show the .complete <p>
		document.querySelector("#" + id + " .pending").className += " hide"
		completeElem = document.querySelector("#" + id + " .complete")
		completeElem.className = completeElem.className.split("hide").join("")

	# capture callback
	recordSuccess: (mediaFiles) ->
		console.log "record success"
		
		i = undefined
		path = undefined
		len = undefined
		i = 0
		len = mediaFiles.length
	
		while i < len
			#path = mediaFiles[i].fullPath
			@uploadFile mediaFiles[i]
			i += 1
	
	
	
	
	# do something interesting with the file
	
	# capture error callback
	recordError: (error) ->
		console.log "record failed"
		
		navigator.notification.alert "Error code: " + error.code, null, "Capture Error"

	recordSound: ->

		# start audio capture
		navigator.device.capture.captureAudio @recordSuccess, @recordError,
			duration: 5
			limit: 1
		#startRecordWithSettings
		return
	
		options = { duration: 10 };
	
	
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
		#@mediaRec = new Media(@recordFile.fullPath, @nothing, @nothing)
		#@mediaRec.startRecord()
		#@mediaRec.stopRecord()

	
	nothing: ->
		#console.log "nothing"
		
	recordAudio3: (fileEntry) =>
		$("#record").hide()
		$("#stoprecord").show()
		$("#processingrecord").hide()
	
		#console.log fileEntry.fullPath
		#@recordFile = fileEntry
		@mediaRec = new Media(@recordFile.fullPath, @onSuccess, @onError)
		#console.log "recording to #{@src}"
		
		# Record audio
		@mediaRec.startRecord()
		
		recTime = 0
		recInterval = setInterval(->
			recTime = recTime + 1
			setAudioPosition recTime + " sec"
			#if recTime >= 10
			#	clearInterval recInterval
			#	@mediaRec.stopRecord()
		, 1000)#http://localhost:5000/
		
		
	#	recordAudio2: =>
		#console.log "recordAudio2"
		
		#console.log @getFilePath()
		#@src = "test.wav"#@getFilePath() + "myrecording.wav"
		#console.log "trying to recording to #{@src}"
		#@fileSystem.root.getFile(@src, {create: true}, @recordAudio3, @nothing)
		#@recordAudio3()
	
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
		ft.upload path, @url, ((result) ->
			data = decodeURIComponent result.response
			window.localStorage.setItem "recordResults", data
			window.location.href = 'table.html';
			
		), ((error) ->
			console.log "Error uploading file " + path + ": " + error.code
		),
			fileName: name
	
	# onError Callback 
	#
	onError: (error) ->
		alert "code: " + error.code + "\n" + "message: " + error.message + "\n"
	
	# Set audio position
	# 
	setAudioPosition: (position) ->
		document.getElementById("audio_position").innerHTML = position
	#document.addEventListener "deviceready", onDeviceReady, false
	
	###	
	getImage: ->
		
		# Retrieve image file location from specified source
		navigator.camera.getPicture uploadPhoto, ((message) ->
			alert "get picture failed"
		),
			quality: 50
			destinationType: navigator.camera.DestinationType.FILE_URI
			sourceType: navigator.camera.PictureSourceType.PHOTOLIBRARY
	
	uploadPhoto: (imageURI) ->
		options = new FileUploadOptions()
		options.fileKey = "file"
		options.fileName = imageURI.substr(imageURI.lastIndexOf("/") + 1)
		options.mimeType = "image/jpeg"
		params = new Object()
		params.value1 = "test"
		params.value2 = "param"
		options.params = params
		options.chunkedMode = false
		ft = new FileTransfer()
		ft.upload imageURI, "http://yourdomain.com/upload.php", win, fail, options
	###

#$ ->
window.app = new app()