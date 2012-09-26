window.BEATmatic = {}

delay = (ms, func) ->
	setTimeout func, ms

class ui
	constructor: ->
		$(".gotoMain").click =>
			@switch "main"
		
		$(".gotoShare").click =>
			@switch "share"
			
		$("#tutorialBtn").click =>
			@playTutorial()
			#@switch "tutorialVideo"
			#$("#tutorialVideoE")[0].play()
			#$("video").bind "ended", =>
			#   @switch "main"
		
		#$("#tutorialVideoE").click =>
		#	$("#tutorialVideoE")[0].stop()
		#	@switch "main"
			
		$("#demoBtn").click =>	
			BEATmatic.play.setup2()
			@switch "synth2"
			
		#$("#recordBtn").click =>	
		#	BEATmatic.play.setup("demo")
		#	BEATmatic.ui.switch "synth2"
			
			
		###
		$(".color").each (i) ->
			position = $(this).position()
			console.log position
			console.log "min: " + position.top + " / max: " + parseInt(position.top + $(this).height())
			$(this).scrollspy
				min: position.top
				max: position.top + $(this).height()
				onEnter: (element, position) ->
					console.log "entering " + element.id  if console
					$("body").css "background-color", element.id
	
				onLeave: (element, position) ->
					console.log "leaving " + element.id  if console
		###
		
		
		#	$('body').css('background-color','#eee');
		###
		$("#bars").scrollspy
			#min: $("#bars").offset().top
			onEnter: (element, position) ->
				console?.log "2entering " + element.id
				#$("#nav").addClass "fixed"
		
		#XXXX
		#bar
		$(".wrapper").each (i) ->
			position = $(this).position()
			console.log position
			$("#bars").scrollspy
				#min: $("#bars").offset().top
				onEnter: (element, position) ->
					console?.log "entering " + element.id
					#$("#nav").addClass "fixed"
		###
		b1 = new BEATmatic.SoundBtn("c11")

	playTutorial: (layer) ->
		$(".tutor").show()
		@switchTutorial 1
		delay 2000, =>
			@switchTutorial 2
			delay 2000, =>
				@switchTutorial 3
				delay 2000, =>
					$(".tutor").hide()
				
	
	switchTutorial: (tutorialNr) ->
		for nr in [1, 2, 3]
			if tutorialNr is nr
				$("#tutor"+nr).css("opacity", 1)
			else
				$("#tutor"+nr).css("opacity", 0.5)		
	
	#playTutorialVideo: ->
	#	DJvideo = $("#tutorialVideoE")[0]
		#$("#DJvideo").prop 'muted', true
		#DJvideo.playbackRate = 1.2
	#	DJvideo.play()	

	switch: (tabid) ->
		for tab in $("#ui").children()
			jtab = $(tab)
			if tab.id is tabid
				jtab.show()
			else
				jtab.hide()
		
		if tabid is "dj"
			BEATmatic.dj.resetButtons()
		
		#if tabid is "tutorialVideo"
		#	@playTutorialVideo()
			#BEATmatic.dj.playVideo()
$ ->
	BEATmatic.ui = new ui()
