window.BEATmatic = {}

class ui
	constructor: ->
		$(".gotoMain").click =>
			@switch "main"
		
		$(".gotoShare").click =>
			@switch "share"
		

	switch: (tabid) ->
		for tab in $("#ui").children()
			jtab = $(tab)
			if tab.id is tabid
				jtab.show()
			else
				jtab.hide()		
		
		if tab is "dj"
			BEATmatic.sequencer.resetButtons()
$ ->
	BEATmatic.ui = new ui()