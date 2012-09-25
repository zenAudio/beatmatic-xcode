#@codekit-prepend visdata.coffee

delay = (ms, func) ->
	setTimeout func, ms

class BEATmatic.SoundBtn

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
	
	
	
	
	constructor: (btn) ->
		
		"""
		<div class="canvBtn">
			<img src="img/btn-drum.png" alt="" style="position: absolute"/>
			<canvas id="c11"></canvas>
		</div>
		"""
		
		#get a reference to the canvas
		@c = $('#'+btn)[0].getContext("2d");
		
		@c.scale 2, 1
		
		@CX = @WIDTH / 2
		@CY = @HEIGHT / 2
		@VALUE_MULTIPLIER = Math.min(@WIDTH, @HEIGHT) / 15000
		@BEZIER_WIDTH = @radius * 0.05
		
		#FPS = 40
		timeout = 0
		
		#@initCircle()
		for points, i in data
			timeout = timeout + 50#125#(1000 / FPS)
			#console.log "draw " + points
			@timedDrawCircle timeout, points
			#@timedEndCircle 0
		
		@timedEndCircle timeout + 50
		
	
	timedDrawCircle: (timeout, todo) ->
		delay timeout, =>
			@drawCircle todo
			#console.log todo
	
	timedEndCircle: (timeout) ->
		delay timeout, =>
			@c.clearRect 0, 0, @WIDTH, @HEIGHT
			
			@c.lineWidth = @RING_THICKNESS
			#ctx.fillStyle = "black";
			#ctx.fillRect(0,0,100,100);
			@c.strokeStyle = @color#"#24A2E2";
			#@c.lineWidth = 5
			
			#draw a circle
			@c.beginPath();
			@c.arc(@CX, @CY, @radius, 0, Math.PI*2, true);
			#@c.lineWidth = 10
			@c.stroke();
	
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