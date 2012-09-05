class dj
	#buttons = ["h1w1"]
	
	constructor: ->
		@setupClickHandlers()

	
	setupClickHandlers: ->
		for button in $(".djbtn")#.each
			#console.log button
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
		
		@[btnname + "Toggle"]?(btn)
		#console.log btn
		if btn.hasClass "active"
			return if @[btnname + "Off"]?(btn)
		else
			return if @[btnname + "On"]?(btn)
			
		@toggleButtonState btn
		
	kickdrumOn: (btn) ->
		console.log "happy bunny"
	
	kickdrumOff: (btn) ->
		console.log "sad bunny"
	

$ ->
	BEATmatic.dj = new dj()