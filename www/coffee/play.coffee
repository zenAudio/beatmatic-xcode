class play
	loopTimers: {}
	swipeSampleLayover: false
	swipeVolumeLayover: false
	folder: "sounds/"
	lastSample: false
	originalbpm: false
	direction: false
	lastDistance: 0
	
	constructor: ->
		#window.document.addEventListener "deviceready", @deviceready, false
		@deviceready()

	deviceready: =>
		@setup()
		
		$("#next").click =>
			@share()
		
		#originalBG = $("#swipeSampleLayover ul li").css("background-color")
		#fadeColor = "#ddd"
		
	delay: (ms, func) ->
		setTimeout func, ms
		
	setup: =>
		@data = {
			"project": "House Beat 1",
			"bpm": 130,
			"tracks":
				[
					{
						"name": "kick drum"
						"sample": "kick01.wav"
						"icon": "kickdrum.png"
						"score": [100,0,0,0,  0,0,0,100,  100,0,0,0,  0,0,0,0]
					},
					{
						"name": "snare drum"
						"sample": "snare01.wav"
						"icon": "snaredrum.png"
						"score": [0,0,0,0,    100,0,0,0,   0,0,0,0,   100,0,0,0]
					},
					{
						"name": "hi hat"
						"sample": "hihat01.wav"
						"icon": "hihat.png"
						"score": [0,0,100,0,  0,0,100,0,  0,0,100,0,   0,0,100,0]
					}
				]
		}
		
		@recordResults = window.localStorage.getItem "recordResults"
		@recordResults = "demo" unless @recordResults
		
		if @recordResults != "demo"
			console.log "parsing data"
			@data = JSON.parse @recordResults
		else
			console.log "demo data"
			
		

		@generateHTML()
		@loopTracks()
	
	generateHTML: =>
		html = """<table id="hor-minimalist-a" class="fulltable" summary="Matrix">"""
		for track, index in @data.tracks
			html += "<tr>"
			html += """<td class=""><img width="50" height="50" src="img/#{track.icon}" alt="#{track.name}"/></td>"""
			for score, index in track.score
				if score >= 100
					score = 100
				html += """<td class="x#{score} c#{index+1}"></td>"""
			html += "</tr>"
			
			
		html += "</table>"
		$("#matrix").html html
		
		
		$("#hor-minimalist-a").swipe
			click: (e, target) =>
				#console.log @data
				score = e.target.cellIndex
				track = e.target.parentNode.rowIndex
				cell = $($(".c#{score}")[track])
				if cell.hasClass "x100"
					cell.removeClass "x100"
					@data.tracks[track].score[score - 1] = 0
				else
					cell.addClass "x100"
					
					@data.tracks[track].score[score - 1] = 100
		
			swipeStatus: (e, phase, direction, distance) =>
				#swipeCount++
				if phase is "cancel" or phase is "end"
					console.log "****END****"
					@direction = false
					@lastDistance = 0
					
					if @swipeSampleLayover
						$("#swipeSampleLayover").hide()
						@swipeSampleLayover = false
						@stopLoop()
						@loopTracks()
						
					if @swipeVolumeLayover
						$("#swipeVolumeLayover").hide()
						@originalbpm = @data.bpm
						@swipeVolumeLayover = false
					return
				
				if distance <= 5
					return

				
				if direction is "up" or direction is "down"
					@direction = "updown" unless @direction
					return if "updown" != @direction
					
					unless @swipeSampleLayover
						#console.log "*** Show Samples"
						#console.log "*** Show Samples!!!"
						@stopLoop()
						@swipeSampleLayover = true
						###

						if e.pageX
							x = e.pageX
						else
							x = e.touches[0].pageX
						
						if e.pageY
							y = e.pageY
						else
							y = e.touches[0].pageY	
						
						totalHeight = $("body").height()
						layoverHeight = $("#swipeSampleLayover").height()
						offset = 0
						
						
						if y < layoverHeight/2
							#console.log "<"
							offset = layoverHeight/2 - y
							#x = layoverHeight/2
						
						#console.log "totalHeight - y < layoverHeight/2 : #{totalHeight - y} < #{layoverHeight/2} #{totalHeight - y < layoverHeight/2}"
						
						if totalHeight - y < layoverHeight/2
							#console.log ">"
							offset = totalHeight - y - layoverHeight/2
						
						
						#console.log offset
						$("#swipeSampleLayover").css "top", y + offset - layoverHeight/2
						#console.log e.touches
						#console.log e
						$("#swipeSampleLayover").css "left", x - 10
						#$("#swipeSampleLayover").css "left", 15
						###
						$("#swipeSampleLayover").show()
						@samplebase = false
						
					
					
					#have at least 5px differnece from last time
					
					move =  distance - @lastDistance
					console.log "***"
					console.log distance
					console.log @lastDistance
					console.log move
					console.log "***"
					
					
					#mouse move above 10px or below -10
					if (move < 10) and (move > -10)
						console.log "did not move enough"
						console.log move
						return

											
					@lastDistance = distance
					
					track = e.target.parentNode.rowIndex
					sample = @data.tracks[track].sample
					i = sample.indexOf "0"
					n = Number sample[i+1]
					unless @samplebase
						@samplebase = sample[...i]
					
					
					
					if direction is "up"
						n++ unless n >= 7
						
					
					if direction is "down"
						n-- unless n <= 1
						
					
					newsample = @samplebase + 0 + n + sample[i+2...]
					#return
					@playAudio @folder + newsample
					@data.tracks[track].sample = newsample
					
					$("#swipeSampleLayover").html(newsample)
					#alert i = test.indexOf "0"
					
					#test[...i] + test[i+2...]
					
					#volume
					
						
				if direction is "left" or direction is "right"
					@direction = "leftright" unless @direction
					return if "leftright" != @direction
					
					unless @swipeVolumeLayover
						$("#swipeVolumeLayover").show()
						@swipeVolumeLayover = true
					
					offset = Math.round (distance / 2)
					
					if direction is "left"
						offset = offset * -1
						
					$("#swipeVolumeLayover").html "#{@data.bpm + offset} BPM"
					unless @originalbpm
						@originalbpm = @data.bpm
					@data.bpm = @originalbpm + offset
					@stopLoop()
					@loopTracks()
					
				
				return
				
				#$(this).html "You swiped " + swipeCount + " times"
			allowPageScroll: "none"
			threshold: 50
		
		###
		
		$("#hor-minimalist-a").click (e) =>
			#console.log e
			#console.log e.target.parentNode.rowIndex
			#console.log e.target.cellIndex
			
			score = e.target.cellIndex
			track = e.target.parentNode.rowIndex
			cell = $($(".c#{score}")[track])
			if cell.hasClass "x100"
				cell.removeClass "x100"
				@data.tracks[track].score[score - 1] = 0
			else
				cell.addClass "x100"
				@data.tracks[track].score[score - 1] = 100

		###
		
	score: (track, score) ->	
		if @data.tracks[track].score[score-1] >= 100
			@playAudio @folder + @data.tracks[track].sample

			
	
	highlightColumun: (col) ->
		$(".c#{col}").addClass "highlighted"
		col = col - 1
		col = 16 if col is 0
		$(".c#{col}").removeClass "highlighted"
	
	share: =>
		@stopLoop()
		window.localStorage.setItem "score", @data
		window.location.href = 'share.html';
		
		
		
	stopLoop: =>
		for track, loopTimer of @loopTimers
			#console.log loopTimer
			clearInterval loopTimer
			loopTimer = null
		
		$(".highlighted").removeClass "highlighted"
	
	loopTracks: =>
		@loop(0)
		@loop(1)
		@loop(2)
	
	loop: (track) =>
		loopvar = 0
		
		ms = 15000 / @data.bpm
		ms = ms.toFixed(0)
		#console.log "before timer #{loopvar}"
		
		@loopTimers[track] = setInterval(=>
			loopvar = loopvar + 1
			@highlightColumun loopvar
			
			@score track, loopvar			
			if loopvar is 16
				loopvar = 0
				#@stopLoop()

		, ms) #xxx ms per beat
		

	
	# Play audio
	#
	playAudio: (src) ->
		
		if Media?
			
			#return unless Media
			# Create Media object from src
			my_media = new Media(src, @onSuccess, @onError, @onStatus)
			
			# Play audio
			my_media.play()
		
		else
			new Audio(src).play();
		
		# Update @my_media position every second
		###
		unless mediaTimer?
			mediaTimer = setInterval(->
				
				# get @my_media position
				
				# success callback
				@my_media.getCurrentPosition ((position) ->
					setAudioPosition (position) + " sec"  if position > -1
				
				# error callback
				), (e) ->
					console.log "Error getting pos=" + e
					setAudioPosition "Error: " + e
	
			, 1000)
		###
	
	# onSuccess Callback
	#
	onSuccess: ->
		#console.log "playAudio():Audio Success"
		
	onStatus: (status) ->
		#if status is 4
		#	console.log "playAudio():Audio Status#{status}"
		#	console.log @
	
	# onError Callback 
	#
	onError: (error) ->
		alert "code: " + error.code + "\n" + "message: " + error.message + "\n"
	
	# Set audio position
	# 
	#setAudioPosition: (position) ->
	#	document.getElementById("audio_position").innerHTML = position


window.play = new play()