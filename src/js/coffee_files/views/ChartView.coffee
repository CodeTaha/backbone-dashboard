# ChartView starts here
ChartView = Backbone.View.extend {
	el: "#chartArea" # Div used for this view

	events: { #none for now

	} 

	# FUNCTION: initialize
	initialize: (options) ->
		_.bindAll this, 'render', 'renderReport', 'getTemplates', 'fetchTemplateDetails', 'renderTemplates','callChartTab', 'updateSelections', 'createNewChart' # binding all the functions using this/@
		
		@username = options.username
		@user_id = options.user_id
		@key = options.key
		@showDataAutomatically = options.showDataAutomatically
		#console.log "ChartView Init -> 1"
		@$el.empty()
		@counter = 1 #initializing counter to give ids
		@$el.hide() #hiding so that the charts dont rendr on homepage

		@templates = [] # To stores template data

		@chartSelectionModel = new poimapper.models.ChartSelectionModel()
		@chartReportCollection = new poimapper.ChartCollection()
		@chartReportCollection.bind 'add', @callChartTab
		
		@$el.append @modal_template() # Appending div which will be used to maximize charts
		$("#chartpoitypes").append '
		<li class="dropdown-header templateheader">Saved Reports</li>'
#		<li>
#			<a href="#" id="createChart_id" data-target="#maxModal">Create New
#			<span class="glyphicon glyphicon-plus-sign" aria-hidden="true"></span>
#			</a>
#		</li>' # Lapelling headers for dropdown

# FUNCTION: render
	render: ->
		#console.log "chartview	render called"
		@getTemplates() # Fetches JSON templates for the user
		$("#chartTab").show();
		
		#Help video
		#console.log("ChartView clientpersistmodel",window.clientPersistModel)
		readyStateCheckInterval = setInterval(()-> 
			if document.readyState is "complete"
					clearInterval(readyStateCheckInterval)
					#startD = new Date("2016-04-14 16:09:01.0")
					#lastLogin = new Date(window.clientPersistModel.get("lastLogin"))
					#showVid = (if lastLogin<startD then true else false)
					showVid = (if window.clientPersistModel.get("chartVid") is "true" then true else false)
					
					if showVid
						bootbox.dialog {
							title:"New Feature: Tutorial to use Charts",
							message: '<center><iframe width="640" height="360" src="https://www.youtube.com/embed/mMdOIuLorE8?rel=0" frameborder="0" allowfullscreen></iframe></center>',
							buttons: {
								danger:{
									label: "Close",
									className: "btn-primary",
									callback: ->
										#Example.show("great success");
										#console.log("dont show again");
										window.clientPersistModel.set chartVid : "false"
								}
							}
						}
						window.clientPersistModel.set chartVid : "false"
		, 10);
	
		
		


	# FUNCTION:createNewChart has the form options to create a new chart
	createNewChart: () ->
		# TODO uncomment the form part to fix loading time
		$( "#chartButton" ).trigger( "click" )
		form = root.formCollection
		self = @
		#console.log 'form', form.slice(0,3)
		if form.length == 0
		# TODO remove everythn in if loop, just keep bootbox.alert
			bootbox.alert "Please wait for the forms to load"
		else
			#console.log "forms", form
			therealname = {}
			options = []
			form.each (model) ->
				unless model.get("type") is "TABLE"
					_.each model.get("questionPage"), (page) ->
						_.each page.question, (question) ->
							if question.type is "TableQuestion" and question.inVisible is false
								# store the fucking name
								tm = window.formCollection.findWhere({"ref": question.table.columns.relation[0].ref})
								therealname[tm.id] = question.text

			form.each (model) ->

				if not model.get("isChild") and model.get("type") is "POI"
					options.push {"name":model.get("name"), "value":model.get("id")}
				else if model.get("isChild") and model.get("type") is "POI"
					options.push {"name": "Subform: #{model.get("name")}", "value": model.get("id")}
				else if model.get("isChild") and model.get("type") is "TABLE"
					unless therealname[model.id] is `undefined`
							options.push {"name": "Table: #{model.get("name")}", "value": model.get("id")}

			bootbox.dialog {
									title: "Create a New Report",
									message:
										'<div class="row">  ' +
											'<div class="col-md-12"> ' +
												'<form class="form-horizontal"> ' +
													'<div class="form-group"> ' +
														'<label class="col-md-4 control-label" for="report_title">Report Name</label> ' +
														'<div class="col-md-4"> ' +
															'<input type="text" id="report_title" name="report_title" type="text" value="'+"New Report-"+@counter+'" placeholder="Enter Report Name" class="form-control input-md"/>' +
														'</div> ' +
													'</div> ' +
													'<div class="form-group"> ' +
														'<label class="col-md-4 control-label" for="form_id">Select Form</label> ' +
														'<div class="col-md-4"> ' +
															'<select id="form_id" name="form_id" type="text" placeholder="Select Form" class="form-control input-md"></select>' +
														'</div> ' +
													'</div> ' +
													'<div class="form-group"> ' +
														'<label class="col-md-4 control-label" for="chart_type">Type of Chart</label> ' +
														'<div class="col-md-4"> ' +
															'<select id="chart_type" name="chart_type" type="text" placeholder="Select chart type" class="form-control input-md">'+
																'<option value="0">Bar Chart</option>'+
																'<option value="3">Pie Chart</option>'+
															'</select>' +
														'</div> ' +
													'</div> ' +
												'</form> </div>  </div>'
									buttons: {
										success: {
											label: "Define Report",
											className: "btn-success",
											callback: ->
												#console.log "form submitted"

												chartReportModel = new poimapper.models.ChartReportModel
												chartReportModel.set form_id: $("#form_id").val()
												chartReportModel.set template: false
												chartReportModel.set newChart: true
												chartReportModel.set report_title: $("#report_title").val()
												chartReportModel.set template_data: {
													"url":"",
													"template_params": {
														"poi": $("#form_id").val(),
														"includelocation": "0",
														"newdata": "1",
														"chart": $("#chart_type").val(),
														"type": "SUM",
														"questions": "Quality_of_water,Ownership,Water_availability,Type_of_water_source",
														"locs": [],
														"levels": [],
														"users": "",
														"fromdate": "",
														"todate": "",
														"timeinfo": "0",
														"userinfo": "0",
														"legendid": "2",
														"reportType": "0",
														"locationLevels": "1",
														"combinenumericfields": "0",
														"timeseriestype": "",
														"locationLevelDataFilter": "",
														"orientation": "1",
														"rowquestionid": "",
														"groupid": window.groupID,
														"format": "json",
														"excludenull": "0",
														"subgroup": ""
													},
													"details":{
														"form":  $.grep(options, (e) ->
															e.value == $('#form_id').val())[0].name
													}
												}
												chartReportModel.set report_id: (chartReportModel.get("report_title")+self.counter).replace(/[^A-Z0-9]+/ig, "_")

												self.chartReportCollection.add chartReportModel
												self.counter++


										}
										cancel: {
											label: "cancel",
											className: "btn",
											callback: ->
												#console.log "form cancelled"

										}
									}
			}
			$.each options,(index, opt) ->
				$("#form_id").append new Option(opt.name,opt.value), null



	# FUNCTION:callChartTab is called whenever a new model is added to chartReportCollection. callChartTab creates the <li> for dropdown and loads other data for the model
	callChartTab: (chartReportModel)->
		#console.log "callChartTab 2 ", chartReportModel
		chartTab = new poimapper.views.ChartTab(
			 model: chartReportModel
			 parent: this
			 chartSelectionModel: @chartSelectionModel
		)
		@counter++
		if chartReportModel.get("template")
			$("#chartpoitypes").append chartTab.appendList().$el
		else
			#@$el.append chartTab.createPanel().$el
			chartTab.render()
			$("#chartpoitypes .templateheader").before chartTab.appendList().$el
		this


	# FUNCTION:renderReport creates models for reports and adds them to the chartReportCollection
	renderReport: (report_data) ->
		self = this
		chartReportModel = new poimapper.models.ChartReportModel
		chartReportModel.set report_title: "Reporttest"+@counter
		chartReportModel.set template: false
		# To get form name
		#form = if root.formCollection.get(report_data.template_params.poi)
		#form = if form == undefined then '' else form.get("ref")
		#console.log("reportdata", JSON.stringify(report_data))
		form = (if root.formCollection.get(report_data.template_params.poi)? then root.formCollection.get(report_data.template_params.poi) else '')
		report_data.details = {}
		report_data.details.form = form

		chartReportModel.set report_id: chartReportModel.get("report_title").replace(/[^A-Z0-9]+/ig, "_")
		# This is the actual data used for rendering charts
		if report_data.data == undefined
			setTimeout(->
				callback = (data, status) ->
					#report_data.data = data
					# template_data contains url to fetch chart data, template_params to save template later and actual data already loaded
					chartReportModel.set template_data: report_data
					chartReportModel.set data:data
					self.chartReportCollection.add chartReportModel
					#console.log "stringify",JSON.stringify(report_data)
				$.get report_data.url, callback
			)
		else
			# template_data contains url to fetch chart data, template_params to save template later and actual data already loaded
			chartReportModel.set data: report_data.data
			delete report_data.data
			chartReportModel.set template_data: report_data

			@chartReportCollection.add chartReportModel

		#console.log "renderReport->", chartReportModel
		#console.log "stringify",JSON.stringify(chartReportModel)
		@counter++


	# FUNCTION:renderTemplates Same as renderReport but used for rendering saved templates
	renderTemplates: (element) ->
		self = this
		$.ajax
						type: "GET",
						async: false,
						url: "/json/app/applytemplate/" + element.report_id
						headers:
								"Content-Type": "application/json"
								userid: self.username
								key: self.key
						success: (result) ->
							#console.log "renderTemplates", element
							element['url']=result.message
							chartReportModel = new poimapper.models.ChartReportModel
							chartReportModel.set report_title: element.report_name
							chartReportModel.set template: true
							chartReportModel.set template_data: element
							chartReportModel.set report_id: (chartReportModel.get("report_title")+@counter).replace(/[^A-Z0-9]+/ig, "_")
							self.chartReportCollection.add chartReportModel
							@counter++
		this


	# renderTemplates: getTemplates() Fetches the name and IDS of all the templates which is later filtered by another function to use only json templates
	getTemplates: ()->
		self = this
		$.ajax
						type: "GET"
						url: "/json/app/reports/#{@user_id}"
						headers:
								"Content-Type": "application/json"
								userid: @username
								key: @key
						success: (results) ->
								i = 0
								while i < results.length
									# To filter only JSON templates
									self.fetchTemplateDetails(results[i])
									i++


	# FUNCTION:fetchTemplateDetails	JSON Templates
	fetchTemplateDetails: (element) ->
		self = this
		$.ajax
					type: "GET",
					url: baseUrl + "app/templatedetails/" + element.report_id
					headers:
							"Content-Type": "application/json"
							userid: userName
							key: pwrd
					success: (result) ->
						if result[0].format == 'json'
							element['details'] = result[0]
							self.templates.push(element)
							self.renderTemplates(element)


	# FUNCTION: updateSelections updates the filters selected on the left panel
	updateSelections: (formIds, locations, users,fromDate, toDate, levels) ->
		form = root.formCollection
		#console.log "form",form
		temp_model = new poimapper.models.ChartSelectionModel()
		unless _.isNaN(fromDate)
			date = new Date fromDate
			fromDate = date.getFullYear()+'-'+('0'+(date.getMonth()+1)).slice(-2)+'-'+('0'+date.getDate()).slice(-2)
			temp_model.set fromDate: fromDate

		unless _.isNaN(toDate)
			date = new Date toDate
			toDate = date.getFullYear()+'-'+('0'+(date.getMonth()+1)).slice(-2)+'-'+('0'+date.getDate()).slice(-2)
			temp_model.set toDate: toDate

		temp_model.set formIds: formIds
		temp_model.set locations: locations
		temp_model.set users: users
		temp_model.set levels: levels
		@chartSelectionModel.set(temp_model.toJSON())
		#console.log "updateCurrentSelectionCV", formIds, locations, users, fromDate, toDate, @chartSelectionModel.toJSON()


	# The following templates are used to create chartBoxes and maximizing charts
	panel_template:_.template "<div class='col-md-4 col-lg-4 col-sm-6'><div class=\"panel panel-primary chartBox\">
							<div class=\"panel-heading chartTitle\">
									{{ graph_title }}
									<button type='button' class='btn btn-xs btn-default col-md-2' aria-label='Maximize' style='float:right;' data-target='#myModal' data-toggle='modal' data-id='{{data_id}}'>
										<span class='glyphicon glyphicon-zoom-in' aria-hidden='true'></span>
									</button>
							</div>
							<div class=\"panel-body {{chart_type}}\" id=\"viz_{{ counter }}\"></div>
						</div></div>"
	modal_template:_.template '<div class="modal fade" id="maxModal" tabindex="-1" role="dialog" aria-labelledby="maxModalLabel">
							<div class="modal-dialog modal-lg" id="chart-modal-content" role="document">
								<div class="modal-content">
									<div class="modal-header">
										<button type="button" class="close" data-dismiss="modal" aria-label="Close">close<i class="fa fa-times"></i></button>
										<h4 class="modal-title" id="maxModalLabel">Chart title</h4>
									</div>
									<div class="modal-body" id="max_chart">
										Chart goes here
									</div>
								</div>
							</div>
						</div>'
}
# export the following globals
root = window or this
unless root.poimapper?
	root.poimapper = {}

unless root.poimapper.views?
	root.poimapper.views = {}

root.poimapper.views.ChartView = ChartView
