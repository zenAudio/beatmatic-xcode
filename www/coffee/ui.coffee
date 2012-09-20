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
			BEATmatic.play.setup("demo")
			@switch "synth2"
			
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
