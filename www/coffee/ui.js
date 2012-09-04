window.BEATmatic = {}

class ui
	switch: (tab) ->
		for tab in $("ui").children
			if tab.name is tab
				tab.show()
			else
				tab.hide()
		
		
$->
	BEATmatic.ui = new ui