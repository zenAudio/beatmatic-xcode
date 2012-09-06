class dj	
	constructor: ->
		BEATmatic.sequencer.sampleTracks = 
			baseline: "Synth_5.wav"
			percussion: "Percussion_2.wav"
			synth: "Synth_12.wav"
			melodic: "Melodic_5.wav"
		
		
		$(".returnbtn").click ->
			BEATmatic.sequencer.stopCoreLoop()
			BEATmatic.ui.switch("main")
			false
		
		@setupClickHandlers()

	
	setupClickHandlers: ->
		#console.log "setupClickHandlers"
		for button in $(".djbtn")#.each
			@setupClickHandler button#(this).name
	
	setupClickHandler: (button) ->
		button = $ button
		#console.log button
		button.click @clickHandler
			
	toggleButtonState: (button) ->
		if button.hasClass "active"
			button.removeClass "active"
		else
			button.addClass "active"
			
	clickHandler: (e) =>
		#console.log "clickHandler"
		btn =  window.b1 = $ e.currentTarget
		btnname = btn.attr("name")
		i = btnname.indexOf "."
		btnbase = btnname[...i]
		btnspecific = btnname[i+1...]
		
		@[btnbase + "Toggle"]?(btnspecific, btn)
		#console.log btn
		if btn.hasClass "active"
			#return if 
			@[btnbase + "Off"]?(btnspecific, btn)
		else
			#return if 
			@[btnbase + "On"]?(btnspecific, btn)
			
		@toggleButtonState btn
	
	
	
	drumsOn: (drum, btn) ->
		switch drum
			when "kickdrum" then BEATmatic.sequencer.unMuteDrum 0
			when "snare" then BEATmatic.sequencer.unMuteDrum 1
			when "hihat" then BEATmatic.sequencer.unMuteDrum 2
			else console.log "unknown drum"
		false
			
		#console.log "happy bunny"
		#BEATmatic.sequencer
		#sampleTacksToPlay: []
		#sampleTracks: {}
	
	
	
	drumsOff: (drum, btn) ->
		switch drum
			when "kickdrum" then BEATmatic.sequencer.muteDrum 0
			when "snare" then BEATmatic.sequencer.muteDrum 1
			when "hihat" then BEATmatic.sequencer.muteDrum 2
			else console.log "unknown drum"
		false
	
	
		
	sampleOn: (sample, btn) ->
		console.log "sampleOn"
		BEATmatic.sequencer.playSample sample
		#BEATmatic.sequencer.sampleTacksToPlay.push sample
		false
	
	sampleOff: (sample, btn) ->
		BEATmatic.sequencer.stopSample sample
		#i = $.inArray(sample, BEATmatic.sequencer.sampleTacksToPlay)
		#return  if i is -1
		#BEATmatic.sequencer.sampleTacksToPlay.splice i, 1
		false
	

$ ->
	BEATmatic.dj = new dj()