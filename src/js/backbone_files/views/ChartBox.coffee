# ChartBox starts here
ChartBox = Backbone.View.extend {
	tagName: 'div'
	className: 'col-sm-6 col-md-6 col-lg-4'
	events: {
		"click button.maxButton": "maxMinChart" #whenever the titlebar of chartbox is clicked, the chart is maximized
		"click button.download": "downloadChart"
	}
	initialize: (options) ->
		_.bindAll this, 'render', 'unrender', 'maxMinChart', 'createChart', 'downloadChart'
		@chart =	new Chart
		@parent = options.parent
		@model.bind('remove', this.unrender)
		@maxMinFlag = false #for maximizing minimizing charts
	render: () ->
		###
		switch @model.get("chart_type")
			when 'bar'
				@chart_type='bar'
			when 'pie'
				@chart_type='pie'
		###
		@chart_type = @model.get("chart_type")
		
		location = if @model.get("location") != null then "<span class='glyphicon glyphicon-map-marker' aria-hidden='true'></span>"+@model.get("location") else "<h5>&nbsp;</h5>"
		#console.log("location", @model.attributes, location)
		if !@model.get("loc_title")?
			$(@el).html @viz_template({
				"graph_title": @model.get("title"),
				"counter": @model.cid,
				"chart_type": @chart_type+"_c",
				"data_id": @model.cid,
				"pois": @model.get("no_of_pois")
			})
		else
			$(@el).html @viz_template({
				"graph_title": location,
				"counter": @model.cid,
				"chart_type": @chart_type+"_c",
				"data_id": @model.cid,
				"pois": @model.get("no_of_pois")
			})
		this


	# FUNCTION: unrender() On refresh when previous chart models are deleted, this function is called due to bind on remove, which removes the chartBox from the panel
	unrender: ()->
		@$el.remove()

	# Saves SVG as .png for download
	downloadChart: () ->
		@$el.append('<canvas id="drawingArea"></canvas>')
		#console.log "Save this svg", "#viz_"+@model.cid, $("#viz_"+@model.cid+" svg").html()
		console.log "Download", @model
		canvg(document.getElementById('drawingArea'),'<svg class="'+@chart_type+"_c"+'" width="'+$("#viz_"+@model.cid+" svg").width()+'" height="'+$("#viz_"+@model.cid+" svg").height()+'">'+$("#viz_"+@model.cid+" svg").html()+'</svg>')#, {scaleWidth:20, scaleHeight:12})
		canvas = document.getElementById('drawingArea')
		img		= canvas.toDataURL("image/png")
		link = document.createElement("a")
		link.download = @model.get("title").replace(/[^A-Z0-9]+/ig, "_")+".png"
		
		if @model.get("location")?
			link.download = @model.get("title").replace(/[^A-Z0-9]+/ig, "_")+"-"+@model.get("location").replace(/[^A-Z0-9]+/ig, "_")+".png"
		link.href = img
		link.click()
		@$("#drawingArea").remove()

	# Creates the chart based on chart_type
	createChart: () ->
		#console.log("createChart", @model,@chart_type)
		switch @chart_type
			when 'bar'
				@bar((err, success)->
					return)
			when 'pie'
				@pie((err, success)->
					return)
			when 'area'
				
				@area((err, success)->
					return)
			when 'line'
				@line((err, success)->
					return)

	# maximizes chart size on click
	maxMinChart: () ->
		@maxMinFlag = !@maxMinFlag
		if @maxMinFlag
			@$el.removeClass()
					.addClass("col-sm-12 col-md-12 col-lg-12 maximizeChart")
			@$("."+@chart_type+"_c").empty()

			@$(".maxButton").html('<i class="fa fa-search-minus"></i>')
		else
			@$el.removeClass()
					.addClass("col-sm-6 col-md-6 col-lg-4")
			@$("."+@chart_type+"_c").empty()

			@$(".maxButton").html('<i class="fa fa-search-plus"></i>')
		@createChart()

	# Calls BAR chart
	bar: (cb) ->
		##console.debug "BAR", @model, @parent.model
		data=@model.get("chart_variables")
		#For combined numeric fields
		if @model.get("numeric") is true and @parent.model.get("template_data").template_params.combinenumericfields is "1" 
			@chart.barCombine "#viz_"+@model.cid, data, @maxMinFlag
		else 
			@chart.bar "#viz_"+@model.cid, data, "key", "value", @model.get("numeric"), @maxMinFlag
		cb null,true

	# Calls PIE chart
	pie: (cb) ->
		data=@model.get("chart_variables")
		@chart.pie "#viz_"+@model.cid, data, "key", "value",@maxMinFlag
		cb null,true

	# Calls AREA chart
	area: (cb) ->
		#console.log "Calling area"
		data =  JSON.parse(@model.get("chart_variables")[0].value)
		parseDate = d3.time.format('%d-%b-%y').parse
		cid = @model.cid
		@chart.area '#viz_' + cid, data, 'x', 'y'

		cb null, true

	# Calls LINE chart
	line: (cb) ->
		#console.log "Calling area"
		data =  JSON.parse(@model.get("chart_variables")[0].value)
		parseDate = d3.time.format('%d-%b-%y').parse
		cid = @model.cid
		@chart.line '#viz_' + cid, data, 'x', 'y'

		cb null, true


	# Template use to render .well	with charts for chartBoxes
	viz_template:_.template '
							<div class="well chartBox">
								<div class="chartTitle row-fluid">
									<div class="col-md-8 graphTitle" title="{{ graph_title }}">
										<div class="row">
											<h5>{{ graph_title }}</h5>
											<h6>POI\'s: {{ pois }}</h6>
										</div>
									</div>
									<button type=\"button\" class=\"btn btn-xs btn-default download\" style="float:right;">
												<i class=\"fa fa-download\"></i>
									</button>
									<!--<button type="button" class="btn btn-xs btn-default maxButton" aria-label="Maximize" style="float:right;" data-target="#maxModal" data-toggle="modal" data-id="{{data_id}}">-->
									<button type="button" class="btn btn-xs btn-default maxButton" aria-label="Maximize" style="float:right;">
										<i class="fa fa-search-plus"></i>
									</button>
								</div>
								<div class="{{chart_type}}" id=\"viz_{{ counter }}\">

								</div>
							</div>'
}
# ChartBox ends here

# export the following globals
root = window or this
unless root.poimapper?
	root.poimapper = {}

unless root.poimapper.views?
	root.poimapper.views = {}

root.poimapper.views.ChartBox = ChartBox
