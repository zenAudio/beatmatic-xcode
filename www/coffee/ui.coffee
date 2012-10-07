window.BEATmatic = {}
BEATmatic.sampleVis = {}

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
			
		#delay 300, =>
		#	@switch "synth"
		

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

	switch: (tabid) ->
		for tab in $("#ui").children()
			jtab = $(tab)
			if tab.id is tabid
				jtab.show()
			else
				jtab.hide()
		
		if tabid is "main"
			BEATmatic.audioEngine.stop()
			BEATmatic.rec.startLevelMeter()
			BEATmatic.play.stopHighlight()
			BEATmatic.dj.stop()
			BEATmatic.rec.switchButtons "recordBtn"
		
		if tabid is "synth"
			BEATmatic.play.setup()
			BEATmatic.rec.stopLevelMeter()
			BEATmatic.audioEngine.play()
			
		if tabid is "dj"
			BEATmatic.play.stopHighlight()
			BEATmatic.rec.stopLevelMeter()
			BEATmatic.dj.setup()

			
$ ->
	BEATmatic.ui = new ui()
	#new FastClick(document.body)
