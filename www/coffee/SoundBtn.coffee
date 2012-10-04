#@codekit-prepend visdata.coffee

data = [[1056,1162,1117,1237,682,792,153,634,139,0,198,289,94,236,301,193,0,56,75,9,0,17,107,0,0,0,88,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[1111,920,680,287,0,246,116,361,134,0,210,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]] unless data

retina = (if window.devicePixelRatio > 1 then "@2x" else "")

class BEATmatic.Btn
	@instances: 1
	instanceID: null
	color: "#24A2E2"
	playing: false
	
	constructor: (partentDiv, ico, color, btnFunction) ->
		@instanceID = BEATmatic.SoundBtn.instances++
		if btnFunction
			@btnFunction = btnFunction
		else
			@btnFunction = @clickHandler
		
		@partentDiv = partentDiv.append """
		<div id="SB#{@instanceID}" class="canvBtn #{ico}" style="background-image: url(img/#{ico}#{retina}.png);">
			<canvas id="SBC#{@instanceID}"></canvas>
		</div>
		"""
		
		@color = color if color
		
		$("SB#{@instanceID}").data "btn", 111
		
		$("#SBC#{@instanceID}").swipe
			
			click: (e, target) =>
				#BEATmatic.dj.clickHandler(e)
				@btnFunction()
		
	clickHandler: =>
		if @playing
			@stop()
			@playing = false
		else
			@play()
			@playing = true
			
		@soundGroup = "synth"
		@soundID = 0

class BEATmatic.SoundBtn
	@instances: 1
	instanceID: null
	#FPS: 40
	BG_COLOR: "#000000"
	color: "#24A2E2"
	c: null
	
	radius: 55
	prevPoints: []
	WIDTH: 150
	HEIGHT: 150
	
	#VALUE_MULTIPLIER: Math.min(@WIDTH, @HEIGHT) / 15000
	RING_THICKNESS: 2#1.4
	#CX: @WIDTH / 2     
	#CY: @HEIGHT / 2
	MAX_MOVE: 0.8
	#BEZIER_WIDTH: @radius * 0.05
	
	#div, color, sample, playFunction?
	ms: 125
	timeout: false
	playing: false
	animations: true
	
	
	#div, "btn-drum", "#24A2E2"
	constructor: (partentDiv, ico, color, btnFunction) ->
		#@retina = window.devicePixelRatio > 1 ? "@2x" : ""
		@instanceID = BEATmatic.SoundBtn.instances++
		if btnFunction
			@btnFunction = btnFunction
		else
			@btnFunction = @clickHandler
		#@instanceID = BEATmatic.SoundBtn.instances
		
		@partentDiv = partentDiv.append """
		<div id="SB#{@instanceID}" class="canvBtn #{ico}" style="background-image: url(img/#{ico}#{retina}.png);">
			<canvas id="SBC#{@instanceID}"></canvas>
		</div>
		"""
		@length = data.length
		
		@color = color if color
		#@div = div
		
		@c = $('#SBC'+@instanceID)[0].getContext("2d");
		
		@c.scale 2, 1
		
		@CX = @WIDTH / 2
		@CY = @HEIGHT / 2
		@VALUE_MULTIPLIER = Math.min(@WIDTH, @HEIGHT) / 15000
		@BEZIER_WIDTH = @radius * 0.05
		
		@clearCircle()
		
		$("SB#{@instanceID}").data "btn", 222
		#console.log 
		
		$("#SBC#{@instanceID}").swipe
			click: (e, target) =>
				#BEATmatic.dj.clickHandler(e)
				@btnFunction()
	
	clickHandler: =>
		@toggle()
			
		@soundGroup = "synth"
		@soundID = 0 
		
		try
			#console.log "Playing sample in group #{@soundGroup} with ID #{@soundID}"
			#BEATmatic.audioEngine.toggleLoop @soundGroup, @soundID
			BEATmatic.audioEngine.toggleLoop("Bass", 0)
		catch e
			console.log "Failed playing sample in group #{@soundGroup} with ID #{@soundID}"
			console.log e.message
		
	delay: (ms, func) ->
		setTimeout func, ms	
	
	toggle: =>
		#console.log "Called toggle"
		if @playing
			@stop()
		else
			@play()
	
	play: ->
		unless @playing
			if @animations
				@playOne(-1)
			else
				#@RING_THICKNESS = 4
				@clearCircle(true)
			@playing = true
		
		
	playOne: (i) =>
		i++
		@drawCircle data[i]
		
		unless i is (@length - 1)
			#console.log "playing "+i
			#console.log "of "+data[i]
			#console.log "of "+data.length
			
			@timeout = @delay @ms, =>
				@playOne i
		else
			#finish
			#console.log "finished!!!"
			@timeout = @delay @ms, =>
				@clearCircle()
	
	stop: ->
		clearTimeout @timeout
		#@RING_THICKNESS = 2
		@clearCircle()
		@playing = false
	###
	timedDrawCircle: (timeout, todo) ->
		#console.log timeout
		@delay timeout, =>
			@drawCircle todo
			#console.log todo
	
	timedEndCircle: (timeout) ->
		@delay timeout, =>
			@clearCircle()
	###
	clearCircle: (playing = false) ->
		#@playing = false
		@c.clearRect 0, 0, @WIDTH, @HEIGHT
		
		#@c.lineWidth = @RING_THICKNESS
		
		if playing
			@c.lineWidth = 4
			@c.shadowOffsetX = 0
			@c.shadowOffsetY = 0
			@c.shadowBlur = 4
			@c.shadowColor = @color
		else
			@c.lineWidth = @RING_THICKNESS
			@c.shadowBlur = 0
		#else
			
		#ctx.fillStyle = "black";
		#ctx.fillRect(0,0,100,100);
		@c.strokeStyle = @color#"#24A2E2";
		#@c.lineWidth = 5
		
		#draw a circle
		@c.beginPath();
		@c.arc(@CX, @CY, @radius, 0, Math.PI*2, true);
		#@c.lineWidth = 10
		@c.stroke();
	###
	initCircle: (circumference) ->
		#circumference = 1 - (data[0].t - now) / INIT_TIME
		#circumference = Math.min(1, circumference)
		
		# Draw line
		@c.strokeStyle = color
		@c.lineWidth = @RING_THICKNESS
		@c.globalCompositeOperation = "source-over"
		@c.beginPath()
		@c.arc @CX, @CY, @radius - @RING_THICKNESS / 2, Math.PI / 2 * circumference, Math.PI * 2 * circumference + Math.PI / 2 * circumference, false
		@c.stroke()	
	###	
	drawCircle: (points) ->
		#console.log "drawCircle::" + points
		@c.clearRect 0, 0, @WIDTH, @HEIGHT

		# Outer shape
		@c.fillStyle = @color#"#24A2E2"
		@c.globalCompositeOperation = "source-over"
		@c.beginPath()
		j = 0
		
		while j < points.length
			angle = Math.PI * 2 / points.length * j + Math.PI / 2
			newAmp = points[j] * @VALUE_MULTIPLIER
			
			# If new movement is greater than @MAX_MOVE, throttle it
			newAmp = @prevPoints[j].amp - @MAX_MOVE  if @prevPoints[j]? and @prevPoints[j].amp > newAmp + @MAX_MOVE
			x = @CX + Math.cos(angle) * (@radius + newAmp)
			y = @CY + Math.sin(angle) * (@radius + newAmp)
			@prevPoints[j] =
				x: x
				y: y
				amp: newAmp
		
			if j is 0
				@c.moveTo x, y
			else
				prevAngle = Math.PI * 2 / points.length * (j - 1) + Math.PI / 2
				cp1x = @prevPoints[j - 1].x + Math.cos(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp1y = @prevPoints[j - 1].y + Math.sin(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp2x = x + Math.cos(angle - Math.PI / 2) * @BEZIER_WIDTH
				cp2y = y + Math.sin(angle - Math.PI / 2) * @BEZIER_WIDTH
				@c.bezierCurveTo cp1x, cp1y, cp2x, cp2y, x, y
			if j is points.length - 1
				prevAngle = angle
				angle = Math.PI / 2
				cp1x = x + Math.cos(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp1y = y + Math.sin(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp2x = @prevPoints[0].x + Math.cos(angle - Math.PI / 2) * @BEZIER_WIDTH
				cp2y = @prevPoints[0].y + Math.sin(angle - Math.PI / 2) * @BEZIER_WIDTH
				@c.bezierCurveTo cp1x, cp1y, cp2x, cp2y, @prevPoints[0].x, @prevPoints[0].y
			j++
		@c.closePath()
		@c.fill()
		
		# Inner shape
		@c.fillStyle = @BG_COLOR
		@c.globalCompositeOperation = "xor"
		@c.beginPath()
		j = 0
		
		while j < points.length
			angle = Math.PI * 2 / points.length * j + Math.PI / 2
			newAmp = @prevPoints[j].amp
			x = @CX + Math.cos(angle) * (@radius - @RING_THICKNESS - newAmp)
			y = @CY + Math.sin(angle) * (@radius - @RING_THICKNESS - newAmp)
			@prevPoints[j] =
				x: x
				y: y
				amp: newAmp
		
			if j is 0
				@c.moveTo x, y
			else
				prevAngle = Math.PI * 2 / points.length * (j - 1) + Math.PI / 2
				cp1x = @prevPoints[j - 1].x + Math.cos(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp1y = @prevPoints[j - 1].y + Math.sin(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp2x = x + Math.cos(angle - Math.PI / 2) * @BEZIER_WIDTH
				cp2y = y + Math.sin(angle - Math.PI / 2) * @BEZIER_WIDTH
				@c.bezierCurveTo cp1x, cp1y, cp2x, cp2y, x, y
			if j is points.length - 1
				prevAngle = angle
				angle = Math.PI / 2
				cp1x = x + Math.cos(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp1y = y + Math.sin(prevAngle + Math.PI / 2) * @BEZIER_WIDTH
				cp2x = @prevPoints[0].x + Math.cos(angle - Math.PI / 2) * @BEZIER_WIDTH
				cp2y = @prevPoints[0].y + Math.sin(angle - Math.PI / 2) * @BEZIER_WIDTH
				@c.bezierCurveTo cp1x, cp1y, cp2x, cp2y, @prevPoints[0].x, @prevPoints[0].y
			j++
		@c.closePath()
		@c.fill()
