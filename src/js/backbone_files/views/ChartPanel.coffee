# ChartPanel starts here
ChartPanel = Backbone.View.extend {
	tagName: "div" # Div used for this view

	events: { #none for now
		"click button.close_chartPanel": "closeChartPanel"
		"click button.delete_chartPanel": "deleteTemplate"
		"click button.save_chartPanel": "saveTemplate"
		"click button.downloadReports": "downloadReports"
		"click .info-button": "showInfo"
		"click button.refresh_chartPanel": "updateSelections"
		#"click button#check": "fetchReport"
		"click button#close": "save_close"
		"click button#editReport": "editReport"
	}

	initialize: (options) ->
		_.bindAll this,'render','closeChartPanel','appendChart','createChartModels', 'show_hide', 'unrender', 'deleteTemplate', 'saveTemplate', 'changeReport_Title', 'downloadReports', 'showInfo', 'selectionChange', 'updateSelections', 'fetchReport', 'createNewReport', 'save_close', 'editReport'
		@parent = options.parent
		@chartSelectionModel = options.chartSelectionModel
		@superParent = options.superParent
		@model.bind('remove', this.unrender)
		# This contains all the charts. One panel is assigned to one collection
		@chartCollection = new poimapper.ChartCollection()
		# When left panel selection changes, @chartSelectionModel is changed my ChartView and refresh button pops up for each collection
		@listenTo(@chartSelectionModel, 'change:locations change:fromDate change:toDate change:users', _.debounce(@selectionChange, 1))
		# Whenever a model is added to the collection, ChartBox view is called to render charts through appendChart
		@chartCollection.bind 'add', @appendChart
		# Model Binding events
		@model.on("change:report_title",@changeReport_Title)


	# FUNCTION: render() appends a specific panel depending whether it is a template or just a temp report
	render: () ->
		if @model.get("template")
			@$el.append @panel_template({
				"report_title": @model.get("report_title")
				"report_id": @model.get("template_data").report_id
				"template_class": "delete_chartPanel"
				"btn_class": "danger"
				"icon_class": "trash"
				"area_label": "Delete Template"
				#"form": @model.get("template_data").details.form + "	(" + @model.get("data").chart1.no_of_pois + ")"
			})
		else
			@$el.append @panel_template({
				"report_title": @model.get("report_title")
				"report_id": @model.get("report_id")
				"template_class": "save_chartPanel"
				"btn_class": "primary"
				"icon_class": "floppy-o"
				"area_label": "Save As Template"
			})
		@$(".refreshing").hide()
		# If its a new chart
		if @model.get("newChart")
			@$('.chartPanelOptions').hide()
			#@$('.content').append @newReport_template({})
			@$('.panel-body').prepend @createNewReport().render().$el
			@chartNew.newReport_setForm()
			#@$(".content").append("<div><br/><h6></h6><ul><li>Select the questions</li><li>Numerical questions require an X-axis parameter</li><li>Filters <i class='fa fa-filter'></i> like date, users and location are provided</li><li>Check appropriate Settings <i class='fa fa-cog'></i></li><li><h3> Click 'Render' to generate the report.</h3> </li><li>After finishing, click 'Done'.</li></ul></div>")

		@$('.refresh_chartPanel').hide()
		#console.log "New Report ", @model.toJSON()
		return this


	#FUNCTION: createNewReport() creates a view for creating new Report
	createNewReport: () ->
		#console.log "ChartPanel Model", @model
		@chartNew = new poimapper.views.ChartNew(
			model: @model
			parent: this
			superParent: @superParent
			chartSelectionModel: @chartSelectionModel
		)
		return @chartNew


	# FUNCTION:selectionChange Shows the refresh button whenever selection on left panel changes
	selectionChange: () ->
		@$('.refresh_chartPanel').show()


	# FUNCTION: createChartModels() creates models that are used bu ChartBox to create charts. All the cleaning and specifying datatype needs to be done within this function
	createChartModels: () ->
		while model = @chartCollection.first()
			model.destroy()
		@$('.content').empty()
		@$('.refresh_chartPanel').hide()
		#console.log "createChartModels,", @model
		# If charts are separated by location
		@byLocation = parseInt(@model.get("template_data").template_params.reportType)
		@locationArr = []
		# Combining numric charts into one if there are multiple numeric charts
		if @model.get("template_data").template_params.combinenumericfields is "1"
			cdata={'bar':{'flag':false,'data':{}}}
			temp_data = @model.get("data")
			$.each temp_data, (key,value)=>
				if value.numeric and value.chart_type is "bar"
					unless cdata.bar.flag
						cdata.bar.data['title'] = "Combined Numeric Fields"
						cdata.bar.data['chart_type'] = "bar"
						cdata.bar.data['no_of_pois'] = value.no_of_pois
						cdata.bar.data['numeric'] = true
						cdata.bar.data['chart_variables']={}
						cdata.bar.flag=true
					$.each value.chart_variables, (key2, value2)=>
						#console.log "cv", key2
						cdata.bar.data.chart_variables[key2] = value2
					delete temp_data[key]
			
			if cdata.bar.flag
				temp_data['CombineNumericBar'] = cdata.bar.data
				@model.set data: temp_data
		
		$.each @model.get("data"), (key,value)=>
			#console.log "Key Value", key, value
			if value.title == undefined || value.chart_type == undefined
				return

			title= value.title
			location = if typeof value.location != 'undefined' then value.location else null
			fdata= []
			chartModel = new poimapper.models.ChartModel
			chartModel.set title: value.title
			chartModel.set chart_type: value.chart_type
			chartModel.set no_of_pois: value.no_of_pois
			chartModel.set numeric: if typeof value.numeric != 'undefined' then value.numeric else false
			chartModel.set location: location

			if value.chart_variables == undefined
				fdata.push {"key":"NO DATA", "value": "0"}
				
			else if chartModel.get("numeric") is true and @model.get("template_data").template_params.combinenumericfields is "1"
				fdata = value.chart_variables
				value.title = "Combined Numeric Fields"
				chartModel.set title: "Combined Numeric Fields"
						
			else
				$.each value.chart_variables, (key2,value2)=>
					#console.log "Key2 Value2", key2, value2
					temp_key = key2.split("-&")

					if temp_key.length is 2
						key2 = temp_key[1]
						
					if value.chart_type is 'area' or value.chart_type is 'line'
						unless key2 is 'No response'
							fdata.push {"key":key2, "value": value2}
					else
						fdata.push {"key":key2, "value": parseInt(value2)}

			chartModel.set chart_variables: fdata

			# Aggregating charts into one group if location
			if @byLocation == 1
				loc_title = value.title.replace(/[^A-Z0-9]+/ig, "_")
				chartModel.set loc_title: loc_title
				if @locationArr.indexOf(loc_title) == -1
					@locationArr.push(loc_title)
					@$('.content').append @location_template({
						"title": value.title
						"class_id": loc_title
					})
				#console.log "keyvalue", key, value


			@chartCollection.add chartModel
		#console.log "createChartModels->",@chartCollection.models


	# FUNCTION: appendChart() renders a chart whenever a new model is created
	appendChart:(chartModel) ->
		#console.log "appendchart2", chartModel
		chartBox = new poimapper.views.ChartBox(
			model : chartModel
			parent: this
		)
		if @byLocation == 1
			loc_title = chartModel.get("loc_title")
			@$('.'+loc_title).append chartBox.render().el
		else
			@$('.content').append chartBox.render().el
		setTimeout(()->
			chartBox.createChart()
		, 0)



	# FUNCTION: updateSelections() if refresh button is clicked, the new template_params are updated, and new url is created to fetch JSON data. The charts are then updated.
	updateSelections:()->
		self = @
		temp = @model.get("template_data")
		temp.template_params.locs = @chartSelectionModel.get("locations")
		temp.template_params.levels = @chartSelectionModel.get("levels")
		temp.template_params.users = @chartSelectionModel.get("users")
		temp.template_params.fromdate = @chartSelectionModel.get("fromDate")
		temp.template_params.todate = @chartSelectionModel.get("toDate")

		@model.set template_data: temp
		@fetchReport(()->
			#console.log("Working")
			self.createChartModels()
		)


	# FUNCTION: fetchReport() if refresh button is clicked, the new template_params are updated, and new url is created to fetch JSON data. The charts are then updated.
	fetchReport:(cb)->
		@$(".refreshing").show()
		key = @superParent.key
		username =	@superParent.username
		user_id =	@superParent.user_id
		t_par = @model.get("template_data").template_params #template_params are values used for regenerating url for fetching data
		
		template_url = "#{baseUrl}app/jasper/#{t_par.poi}/#{t_par.includelocation}/#{t_par.newdata}/#{t_par.chart}/#{t_par.type}?key=" + key + "&userid="+ username + "&user_id="+ user_id + "&questions=" + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + t_par.combinenumericfields + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=json" + "&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup
		#template_url = "#{baseUrl}app/jasper/#{t_par.poi}/#{t_par.includelocation}/#{t_par.newdata}/#{t_par.chart}/#{t_par.type}?key=" + key + "&userid="+ username + "&user_id="+ user_id + "&questions=" + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + 1 + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=json" + "&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup

		template_data = @model.get("template_data")
		template_data.url = template_url
		@model.set template_data: template_data
		console.log "fetchReport", JSON.stringify(@model), template_url

		self = @

		$.ajax
				type: "GET",
				url: template_url#self.model.get("template_data").url,
				success: (result) ->

					self.model.set data: result
					self.$(".refreshing").hide()
					console.log "Refresh Data=",JSON.stringify(self.model), template_url
					#self.createChartModels()
					if cb != null
						cb()
				error:(result) ->
					console.error "Error occured in fetching Report", error
					@$(".refreshing").hide()
					if cb != null
						cb()

		this


	# FUNCTION: closeChartPanel() whenever cross(x) is clicked, it hides the panel by calling the parent-> ChartTab
	closeChartPanel: ()->
		#console.log "closepanel", @parent
		@parent.change()
		#@model.destroy()


	# FUNCTION: unrender() removes the chartPanel whenever its model is destroyed/deleted. This happens only when reports are Templates
	unrender: () ->
		#console.log "Model Destroyed"
		@$el.remove()


	# FUNCTION: deleteTemplate() Deletes the templates permanently
	deleteTemplate: () ->
		self = this
		bootbox.confirm "Remove " + @model.get("report_title") + " permanently from your report selections?", (result)->
			#console.log 'Delete', result
			if result
				#console.log 'start deleting', self.model
				$.ajax
						type: "GET"
						url: baseUrl + "app/deletereport/" + self.model.get("template_data").report_id
						headers:
								"Content-Type": "application/json"
								userid: self.superParent.username
								key: self.superParent.key
						success: (result) ->
								bootbox.alert result.message
								self.model.destroy()


	# FUNCTION: saveTemplate() Saves a temporary report as a Template
	saveTemplate: () ->
		#console.log "saveTemplate", @model.get("template_data")
		self = this
		bootbox.prompt({
			title: "Save Report As",
			value: @model.get("report_title"),
			callback: (result) ->
				if result != null
					#console.log "Saving template", result
					self.model.set report_title: result
					t_par = self.model.get("template_data").template_params #template_params are values used for regenerating url for fetching data
		# Regenerating url before saving template

					template_url = "#{baseUrl}app/jasper/#{t_par.poi}/#{t_par.includelocation}/#{t_par.newdata}/#{t_par.chart}/#{t_par.type}?XXXquestions=" + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + t_par.combinenumericfields + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=" + t_par.format + "&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup

					json = "{ \"report_name\" : \"" + self.model.get("report_title") + "\" , \"parameters\" : \"" + template_url + "\"}"
					#console.log "Saving REport Template", json
					$.ajax
							type: "POST"
							data: json
							url: baseUrl + "app/savereport"
							headers:
									"Content-Type": "application/json"
									userid: self.superParent.username
									key: self.superParent.key

							success: (result) ->
									t = result
									bootbox.alert t.message
									#console.log 'save message', result
		})


	# FUNCTION: changeReport_Title() Changes the name of report title in panel
	changeReport_Title: () ->
		@$(".report_title").html @model.get("report_title")


	# FUNCTION: show_hide() Shows or hides templates when li checkbox or cross is clicked
	show_hide: ()->
		if !@model.get("checked")
			@$el.hide()
		else
			@$el.show()
		this


	# FUNCTION: showInfo() opens a bootbox to show info about the template/report
	# TODO add more details about the template
	showInfo:() ->
		no_of_pois = 0
		temp_data=@model.get("data")
		###
		for key of temp_data
			no_of_pois = temp_data[key].no_of_pois
			break
		###
		bootbox.dialog({
			title: "Details",
			message: '
				<ul>
					<li>
						<b>Form:</b>' + @model.get("template_data").details.form + '
					</li>
				</ul>'
		})


	# FUNCTION: downloadReports() It is called whenever a report's pdf, excel, word needs to be downloaded as a file
	downloadReports: (evt) ->
		report_type = $(evt.currentTarget).data('report_type')
		format = 'pdf'
		switch report_type
			when 1
				format = 'pdf'
			when 2
				format = 'docx'
			when 3
				format = 'xlsx'
		# Regenerating url before downloading
		key = @superParent.key
		username =	@superParent.username
		user_id =	@superParent.user_id
		t_par = @model.get("template_data").template_params #template_params are values used for regenerating url for fetching data
		#console.log 'auths', key, username, user_id

		template_url = "#{baseUrl}app/jasper/#{t_par.poi}/#{t_par.includelocation}/#{t_par.newdata}/#{t_par.chart}/#{t_par.type}?key=" + key + "&userid="+ username + "&user_id="+ user_id + "&questions=" + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + t_par.combinenumericfields + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=" + format + "&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup
		#console.log "download", template_url
		iframe = document.createElement 'iframe'
		iframe.height = 0
		iframe.width = 0
		iframe.src = template_url
		receiver = (evt) ->
				if evt.origin is window.location.origin and evt.data is "no data"
						bootbox.alert "no data in report"

		unless listenerAdded
				window.addEventListener 'message', receiver, false
				listenerAdded = true

		$("body").append iframe


	# FUNCTION: save_close() Save and close @chartNew menu for creating new charts
	save_close: () ->
		self = @
		#console.log("done")
		bootbox.confirm {
				message: 'Are you sure you are done editing the report?<br/> Proceed ',
				buttons: {
						cancel: {
								label: 'Cancel',
								className: 'btn pull-left'
						},
						confirm: {
								label: 'Confirm',
								className: 'btn-success pull-right'
						}
				},
				callback: (result)->
						if result
							self.chartNew.$el.hide()
							self.$('#menuOptions').append('<button type=\"button\" id="editReport" class=\"btn btn-primary btn-sm chartPanelOptions\" data-report_type=\"1\" aria-label=\"Edit\">
															<i class=\"fa fa-pencil\"></i>
														</button>')
							self.$('.chartPanelOptions').show()
		}


	editReport: () ->
		@$('#editReport').remove()
		@$('.chartPanelOptions').hide()
		@chartNew.$el.show()



	# Function: templates used for this view
	panel_template:_.template "<div class='col-md-12 col-lg-12 col-sm-12'	id=\"{{ report_id }}\"><div class=\"panel panel-primary\">
							<div class=\"panel-heading chartTitle\">
								<div class='row'>
									<div class='col-md-8'>

											<h4 class='report_title'>
												{{ report_title }}

												<i class=\"info-button fa fa-info-circle\" title=\"Additional Details\"></i>
												<i class=\'refreshing fa fa-circle-o-notch fa-spin\'></i>
											</h4>

									</div>
									<div class='col-md-4' id='menuOptions'>
										<button type=\"button\" class=\"close close_chartPanel\" aria-label=\"Close\">
											<i class=\"fa fa-times\"></i>
										</button>

										<button type=\"button\" class=\"btn btn-{{btn_class}} btn-sm {{template_class}} chartPanelOptions\" aria-label=\"{{area_label}}\">
											<i class=\"fa fa-{{icon_class}}\"></i>
										</button>

										<div class=\"btn-group chartPanelOptions\" role=\"group\" aria-label=\"Download Reports\">
											<button type=\"button\" class=\"btn btn-danger btn-sm downloadReports \" data-report_type=\"1\" aria-label=\"PDF\">
												<i class=\"fa fa-file-pdf-o pdf\"></i>
											</button>
											<button type=\"button\" class=\"btn btn-info btn-sm downloadReports\" data-report_type=\"2\" aria-label=\"Word\">
												<i class=\"fa fa-file-word-o word\"></i>
											</button>
											<button type=\"button\" class=\"btn btn-success btn-sm downloadReports \" data-report_type=\"3\" aria-label=\"Excel\">
												<i class=\"fa fa-file-excel-o excel\"></i>
											</button>
										</div>
										<button type=\"button\" class=\"btn btn-primary btn-sm refresh_chartPanel chartPanelOptions\" aria-label=\"Refresh\">
												<i class=\"fa fa-refresh\"></i>
										</button>

									</div>
								</div>
							</div>
							<div class=\"panel-body\">
								<div class=\"content\"></div>
							</div>
						</div></div>"

location_template:_.template "<div class='col-md-12 col-lg-12 col-sm-12'\"><div class=\"panel panel-info\">
							<div class=\"panel-heading chartTitle\">
								<h5 class='question_title'>
									<center><b>
										{{ title }}
									</center></b>
								</h5>
							</div>
							<div class=\"panel-body {{ class_id }}\"></div>
						</div></div>"




}
# ChartPanel ends here

# export the following globals
root = window or this
unless root.poimapper?
	root.poimapper = {}

unless root.poimapper.views?
	root.poimapper.views = {}

root.poimapper.views.ChartPanel = ChartPanel
