# ChartNew starts here
ChartNew = Backbone.View.extend {
	tagName: "div" # Div used for this view
	className: "form-inline ChartNew"

	events: {
		"change #legendQuestion_c": "newReport_updateGrouping"
		"click a.drpdwn": "change"
		"click button#render": "renderReport"
		"click #help": "help"
	}

	initialize: (options) ->
		_.bindAll this, 'render', 'addLegendSelectOptions', 'newReport_setForm', 'newReport_changeChartType', 'newReport_addQuestions', 'newReport_addLegendSelectAreaLine', 'newReport_addLegendSelectBarAreaLine', 'newReport_addLegendSelectPie', 'change', 'newReport_updateGrouping', 'renderReport', 'stopLoading', 'help'
		@parent = options.parent
		@chartSelectionModel = options.chartSelectionModel
		@superParent = options.superParent
		@model =  options.model
		@isNumericField = 0
		@chartNewModel = new poimapper.models.ChartNewModel()
		questions = {}
		filters = {
				"editorFilterType":false
				"dateFilterType":false
				"locFilterType":false
		}
		settings = {
				"excludenull": false
				"combinenumericfields":false
		}
		@chartNewModel.set report_title: @model.get("report_title")
		@chartNewModel.set questions: {}
		@chartNewModel.set filters: filters
		@chartNewModel.set settings: settings
		#console.log "ChartNew init Model="+@model.get("report_title"), @model, "ChartNewMOdel",@chartNewModel


	render: () ->
		@$el.append @newReport_template({})
		#@$("#locationLevel_c").prop("disabled",true)
		return  this


	# FUNCTION: newReport_setForm() sets the form parameters for new Report
	newReport_setForm: () ->
			@chartId = Number @model.get("template_data").template_params.chart # 0= Bar. 1= Area, 2= Line, 3= Pie
			#if its a pie chart
			if @chartId is 3
				# Hiding these form values since they are not needed
				@$("#legendQuestion_c").val("0")
				@$(".not_pie").hide()
			@newReport_updateGrouping() # Adds initial location levels for Select Grouping dropdown

			@$(".legendDiv").hide()
			@$("#close").prop("disabled", true)
			@newReport_changeChartType() # calls other functions that loads questions and X-axis for numericals


	# FUNCTION: newReport_updateGrouping() changes new form values when legend changes
	newReport_updateGrouping: () ->
		chartType = @model.get("template_data").template_params.chart
		legendQuestionid = Number @$("#legendQuestion_c").val()
		@$("#locationLevel_c").empty()
		if @chartId is 3 or @isNumericField is 0 # forPie
			i = 0
			while i < locationLabels.length
					if locationLabels[i] isnt null and locationLabels[i] isnt "Location 1" and locationLabels[i] isnt "Location 2" and locationLabels[i] isnt "Location 3" and locationLabels[i] isnt "Location 4" and locationLabels[i] isnt "null"
							@$("#locationLevel_c").append new Option(locationLabels[i], i + 1), null
						i++

		else if legendQuestionid is 1 or legendQuestionid is 2 or legendQuestionid is 3 or legendQuestionid is 4
			i = 0
			while i < window.locationLabels.length
					value_id = i + 1
					if value_id < legendQuestionid
						if window.locationLabels isnt null and window.locationLabels[i] isnt "Location 1" and window.locationLabels[i] isnt "Location 2" and window.locationLabels[i] isnt "Location 3" and window.locationLabels[i] isnt "Location 4" and window.locationLabels[i] isnt "null"
							@$("#locationLevel_c").append new Option(window.locationLabels[i], i + 1), null
					i++

		else
			@$("#locationLevel_c").empty()
			i = 0
			while i < window.locationLabels.length
					if window.locationLabels isnt null and window.locationLabels[i] isnt "Location 1" and window.locationLabels[i] isnt "Location 2" and window.locationLabels[i] isnt "Location 3" and window.locationLabels[i] isnt "Location 4" and window.locationLabels[i] isnt "null"
							@$("#locationLevel_c").append new Option(window.locationLabels[i], i + 1), null
					i++

		@$("#locationLevel_c").prepend new Option("No Grouping", 0), null


	#FUNCTION: newReport_changeChartType() for loading data for charts
	newReport_changeChartType: ()->
		@qSelect = Number @model.get("form_id") # form/poi Id

		@srcSelect = @$("#questionName_c") # id to load questions
		@srcSelect.empty() #clearing questions to Load new

		@legendSelect = @$("#legendQuestion_c")
		@legendSelect.empty()#clearing legend to load new

		@formId = @model.get("form_id")
		@formModel = window.formCollection.get(@formId) # fetch formModel
		pages = @formModel.get("questionPage")
		@page = [] # Will contain all the questions
		#console.log("formMOdel", @formModel)
		if !@formModel.get("hasLocationHierarchy")
			@$("#locationLevel_c").parent().hide()
		if @formModel.get("type") is "TABLE"
			@page = @formModel.get("question")
		else if @formModel.get("type") is 'POI' or @formModel.get("type") is 'AREA' or @formModel.get("type") is 'ROUTE'
			x=0
			while x < pages.length
					y=0
					while y < pages[x].question.length
							pages[x].question[y]["page_number"]=x
							@page.push(pages[x].question[y])
							y++
					x++
		#console.log "newReport_changeChartType-1 =>(chartId)","formModel.attributes", @formModel.attributes, "page=", @page
		@addLegendSelectOptions()


	# FUNCTION: addLegendSelectOptions() adds legend options for x-axis
	addLegendSelectOptions: () ->
		# If AREA or LINE
		if @chartId is 1 or @chartId is 2
			@newReport_addLegendSelectAreaLine()

		# If Bar, AREA or LINE
		if @chartId is 0 or @chartId is 1 or @chartId is 2
			@newReport_addLegendSelectBarAreaLine()

		# If Pie
		if @chartId is 3
			@newReport_addLegendSelectPie()


	# FUNCTION: newReport_addLegendSelectAreaLine() adds X-axis legends and calls function for adding relevant questions
	newReport_addLegendSelectAreaLine:()->
		@legendSelect.append new Option("Day when updated", "modifiedday"), null
		@legendSelect.append new Option("Week when updated", "modifiedweek"), null
		@legendSelect.append new Option("Month when updated", "modifiedmonth"), null
		@legendSelect.append new Option("Year	when updated", "modifiedyear"), null
		@legendSelect.append new Option("Time of day when updated (24 hours)", "modifieddaytime"), null
		@legendSelect.append new Option("Modified Time", "modified"), null


	# FUNCTION: newReport_addLegendSelectBarAreaLine() adds X-axis legends and calls function for adding relevant questions
	newReport_addLegendSelectBarAreaLine:() ->
		i = 0
		if @formModel.get("type") is 'POI' or @formModel.get("type") is 'AREA' or @formModel.get("type") is 'ROUTE'
				while i < locationLabels.length
						if locationLabels[i] isnt null and locationLabels[i] isnt "Location 1" and locationLabels[i] isnt "Location 2" and locationLabels[i] isnt "Location 3" and locationLabels[i] isnt "Location 4" and locationLabels[i] isnt "null"
								@legendSelect.append new Option(locationLabels[i], i + 1), null if @chartId is 0

						else
								#legendSelect.add new Option("location"+ (i+1), i + 1), null

						i++
		j = 0

		while j < @page.length
				qn = @page[j]
				if qn.type is "IdQuestion" or qn.type is "PicturesQuestion" or qn.type is "Part_of_Question" or qn.type is "TimeQuestion" or qn.type is "TableQuestion" or qn.type is "Label" or qn.type is "HeaderQuestion" or qn.id is "phoneEditTime" or qn.id is "portalEditTime" or qn.id is "portalEditEntry" or qn.id is "Location1" or qn.id is "Location2" or qn.id is "Location3" or qn.id is "Location4" or qn.type is "GPSQuestion"
					if qn.id is "user_id"
						#legendSelect.add new Option(qn.text, qn.id), null
					else
						j++
						continue

				else
						if (qn.type is "BooleanQuestion" or qn.type is "SelectOneQuestion"	or qn.type is "SelectMultipleQuestion" or qn.type is "StatusQuestion" or (qn.validationlist isnt undefined and qn.validationlist.length > 0)) and @chartId is 0 and !qn.inVisible
							@legendSelect.append new Option(qn.text+ "-(Page_" + Number(qn.page_number+1) + ")", qn.id), null

						unless qn.type is "NameQuestion"
							if qn.type isnt "SkipQuestion"
								if @chartId is 0 or @chartId is 1 or @chartId is 2
									if (qn.type is "IntQuestion" or qn.type is "FloatQuestion") or (!qn.inVisible and (qn.text is "Count" or qn.text is "count" or qn.id is "countQuestion"))
										#opt = new Option(qn.text+ "-(Page_" + Number(qn.page_number+1) + ")", qn.id)
										#$(opt).attr('isnumber','yes')								
										if @formModel.get("type") is "TABLE"
											@newReport_addQuestions(qn.text, qn.id, 'yes')
										else
											@newReport_addQuestions(qn.text+ "-(Pages_" + Number(qn.page_number+1) + ")", qn.id, 'yes')
										#@srcSelect.append opt, null

									else
										opt = new Option(qn.text+ "-(Page_" + Number(qn.page_number+1) + ")", qn.id)
										$(opt).attr('isnumber','no')
										if (qn.type is "BooleanQuestion" or qn.type is "SelectOneQuestion" or qn.type is "SelectMultipleQuestion" or qn.type is "StatusQuestion" or (qn.validationlist isnt undefined and qn.validationlist.length > 0) or qn.type is "IntQuestion" or qn.type is "FloatQuestion") and !qn.inVisible
											if @formModel.get("type") is "TABLE"
												@newReport_addQuestions(qn.text, qn.id, 'no')
											else
												@newReport_addQuestions(qn.text+ "-(Page_" + Number(qn.page_number+1) + ")", qn.id, 'no')
										
								else
									if (qn.type is "BooleanQuestion" or qn.type is "SelectOneQuestion" or qn.type is "SelectMultipleQuestion" or qn.type is "StatusQuestion" or (qn.validationlist isnt undefined and qn.validationlist.length > 0) or qn.type is "IntQuestion" or qn.type is "FloatQuestion") and !qn.inVisible
										if @formModel.get("type") is "TABLE"
											@newReport_addQuestions(qn.text, qn.id, null)
										else
											@newReport_addQuestions(qn.text+ "-(Page_" + Number(qn.page_number+1) + ")", qn.id, null)
									
							# If Subquestions exists		
							if qn.triggerValues? and !qn.inVisible		
								@addSubQuestions qn,1 
				j++


	# FUNCTION: newReport_addLegendSelectPie() adds X-axis legends(not required for Pie but using to keep consistent structure) and calls function for adding relevant questions
	newReport_addLegendSelectPie: () ->
		j = 0
		while j < @page.length
			qn = @page[j]
			if qn.inVisible or qn.type is "IdQuestion" or qn.type is "PicturesQuestion" or qn.type is "Part_of_Question" or qn.type is "TimeQuestion" or qn.type is "TableQuestion" or qn.type is "Label" or qn.type is "HeaderQuestion" or qn.id is "phoneEditTime" or qn.id is "portalEditTime" or qn.id is "portalEditEntry" or qn.id is "Location1" or qn.id is "Location2" or qn.id is "Location3" or qn.id is "Location4" or qn.type is "GPSQuestion" or qn.type is "ValidationRuleQuestion" or qn.type is "FileQuestion"
					j++
					continue
			else
					if qn.type is "BooleanQuestion" or qn.type is "SelectOneQuestion" or qn.type is "SelectMultipleQuestion" or qn.type is "SkipQuestion" or qn.type is "StatusQuestion" or (qn.validationlist isnt undefined and qn.validationlist.length > 0)
							if qn.type isnt "SkipQuestion"
								@newReport_addQuestions(qn.text+ "-(Page_" + Number(qn.page_number+1) + ")", qn.id, null)

							if qn.triggerValues?
								@addSubQuestions qn,1
			j++


	#FUNCTION: addSubQuestions() adds subquestions
	addSubQuestions: (qn, rowandcolumn)->
		#console.log "addSubquestions Called"
		for triggerValue in qn.triggerValues.triggerValue
				if triggerValue.action.subQuestions?
					for subQs in triggerValue.action.subQuestions.question
						# Create srcSelect for subquestions
						#srcSelect=processSubQuestionsForReport subQs,@srcSelect,@chartid,rowandcolumn
							if subQs.text != undefined
								#handle different chart types. This code is replicated form utilities-old.js processSubQuestionsForReport()
								switch @chartId
									when -1 #for Table
										return
									when -2 # Cross Table
										return
									when 0,1,2 # bar, Area, Line
										if subQs.type =="IntQuestion" || subQs.type =="FloatQuestion" || subQs.type =="SelectOneQuestion" || subQs.type =="SelectMultipleQuestion" || subQs.type =="BooleanQuestion"
											if subQs.type=="IntQuestion" || subQs.type == "FloatQuestion"
												@newReport_addQuestions(subQs.text, subQs.id, 'yes', true)
											else
												@newReport_addQuestions(subQs.text, subQs.id, 'no', true)
									when 3
										if subQs.type =="SelectOneQuestion" || subQs.type =="SelectMultipleQuestion" || subQs.type =="BooleanQuestion"
											@newReport_addQuestions(subQs.text, subQs.id, null, true)


						# If more subquestions
						if subQs.triggerValues?
							@addSubQuestions subQs,rowandcolumn


	# FUNCTION: @newReport_addQuestions() adds questions from the form
	newReport_addQuestions: (qtn_text, qtn_id, isnumber, isSubQtn = false) ->
		obj= {"qtn_text":qtn_text, "qtn_id":qtn_id, "isnumber":isnumber,"checked":false}
		indent = ""
		if isSubQtn
			indent="&nbsp; &nbsp;"
		if isnumber is 'yes'
			qtn_text = qtn_text + "(numeric)"
		questions = @chartNewModel.get("questions")
		questions[qtn_id] = obj
		@chartNewModel.set questions:questions
		@srcSelect.append @qtn_template({
			"qtn_id": qtn_id
			"qtn_text": qtn_text
			"indent": indent
		})


	# FUNCTION: renderReport() when check is clicked, this function updates parameters and calls fetchReport function of parent class i.e ChartPanel.
	renderReport: () ->
		@$("#render").button('loading')
		self = @

		#console.log "renderReport()->", @model
		#newAttr = @model.get("newAttr")
		@params = {}
		@params.fieldsToBeReported = ""
		@params.hasNumericFields = false
		$.each @chartNewModel.get("questions"), (key,value)=>
			if value.checked is true
				#console.log("key value", key, value)
				if @chartId is 0 or @chartId is 1 or @chartId is 2
					if value.isnumber is "yes"
						@params.hasNumericFields = true
				if @params.fieldsToBeReported is ""
					@params.fieldsToBeReported += "" + value.qtn_id
				else
					@params.fieldsToBeReported += ","+ value.qtn_id
		@params.fieldsToBeReported += ""

		# Settings
		@params.combinenumericfields = (if @chartNewModel.get("settings").combinenumericfields then "1" else "0")
		#@params.reportType = (if newAttr.settings.locationreport then "1" else "0")
		@params.excludenull = (if @chartNewModel.get("settings").excludenull then "1" else "0")

		# Filters
		@params.editorFilterType = (if @chartNewModel.get("filters").editorFilterType then "1" else "0")
		@params.dateFilterType = (if @chartNewModel.get("filters").dateFilterType then "1" else "0")
		@params.locFilterType = (if @chartNewModel.get("filters").locFilterType then "1" else "0")

		#Select X-axis/Legend Question
		@params.legendid = @$("#legendQuestion_c").val()
		console.log("legend", @$("#legendQuestion_c").val(), @$("#legendQuestion_c :selected").text())

		#Select Grouping
		@params.reportType = "0"
		@params.locationLevels = (if @$("#locationLevel_c").val() is null then "0" else @$("#locationLevel_c").val())
		if @params.locationLevels != "0"
			@params.reportType = "1" #Locations levels selected therefore change report type

		#console.log "LocationReport", @params.reportType, @params.locationLevels

		@params.includeUsers = "0"
		@params.includelocation = "0" # To be made available only for Table
		@params.locationLevelDataFilter = "" # Not sure where it is used, since the div is displayed fr no types of charts
		@params.orientation = "1" # Just for bar chart. 1 for vertical, 0 for horizontal. However horizontal bar charts are not yet implemented
		@params.format =  "json" #always gonna be json for charts
		@params.subgroup = "" # Not sure
		@params.includetimestamp = "0"
		@params.newdata = "1"
		@params.type = "SUM" #Other selections only available for Table
		@params.rowquestion = "" # Available for Cross Table only
		@params.timeseriestype = "" # Matters for Area and Line only
		if @chartId is 1 or @chartId is 2
			if @params.legendid is "modifiedday"
				@params.legendid = "modified"
				@params.timeseriestype = "DAY"
			else if @params.legendid is "modifiedweek"
					@params.legendid = "modified"
					@params.timeseriestype = "WEEK"
			else if @params.legendid is "modifiedmonth"
					@params.legendid = "modified"
					@params.timeseriestype = "MONTH"
			else if @params.legendid is "modifiedyear"
					@params.legendid = "modified"
					@params.timeseriestype = "YEAR"
			else if @params.legendid is "modifieddaytime"
					@params.legendid = "modified"
					@params.timeseriestype = "TIME"

		template_data = @model.get("template_data")
		template_params = template_data.template_params

		if @params.fieldsToBeReported is ""
			bootbox.alert "Please select a question"
			@stopLoading()
			return
		else
			template_params.questions = @params.fieldsToBeReported
			template_params.newdata = @params.newdata
			template_params.includelocation = @params.includelocation
			template_params.type = @params.type
			template_params.includetimestamp = @params.includetimestamp
			template_params.includeUsers = @params.includeUsers
			template_params.legendid = @params.legendid
			template_params.reportType = @params.reportType
			template_params.locationLevels = @params.locationLevels
			template_params.combinenumericfields = @params.combinenumericfields
			template_params.timeseriestype = @params.timeseriestype
			template_params.locationLevelDataFilter = @params.locationLevelDataFilter
			template_params.orientation = @params.orientation
			template_params.format = @params.format
			template_params.excludenull = @params.excludenull
			template_params.subgroup = @params.subgroup

		#@params.selLocs = getTreeSelectedNodes()
		if @params.dateFilterType is "1"
			template_params.fromdate = @chartSelectionModel.get("fromDate")
			template_params.todate = @chartSelectionModel.get("toDate")
		else
			template_params.fromdate = ""
			template_params.todate = ""

		if @params.editorFilterType is "1"
			template_params.users = @chartSelectionModel.get("users")
		else
			template_params.users = ""

		if @params.locFilterType is "1"
			template_params.locs = @chartSelectionModel.get("locations")
			template_params.levels = @chartSelectionModel.get("levels")
		else
			template_params.locs = ""
			template_params.levels = ""
		template_data.template_params = template_params
		#console.log "template_params",template_params
		@model.set template_data:template_data
		unless @model.get("loaded")
			@$("#close").addClass("btn-warning")
			@$("#close").prop("disabled", false )

		@model.set loaded:true
		#console.log "params", @model, @chartSelectionModel

		setTimeout(()->
			self.parent.fetchReport(()->
				self.parent.createChartModels() #calling method of ChartPanel View
				self.stopLoading()
			) # calling chartPanel to render charts

		, 0);

	# FUNCTION: stopLoading() Resets the the Render button
	stopLoading:()->
		#alert "loading complete"
		@$("#render").button('reset')


	# FUNCTION: change() whenever the user changes some values in the menu, this function is called to update relevant parameters
	change: (evt) ->
		self = this
		$target = $( evt.currentTarget )
		form_attr = $target.attr( 'data-attr' )
		if form_attr=="questions"
			val = $target.attr( 'data-value' )

			chk = !@chartNewModel.get("questions")[val].checked
			#@newAttr.questions[val].checked = chk
			#@model.set newAttr: @newAttr
			questions = @chartNewModel.get("questions")
			questions[val].checked = chk
			@chartNewModel.set questions: questions

			if @chartNewModel.get("questions")[val].isnumber is "yes"
				if chk
					@isNumericField++
				else
					@isNumericField--
				if @isNumericField > 0
					@$(".legendDiv").show()
					@newReport_updateGrouping()
				else
					@$(".legendDiv").hide()
					@newReport_updateGrouping()

		else if form_attr=="filters"
			val = $target.attr( 'data-value' )
			chk = !@chartNewModel.get("filters")[val]
			#@newAttr.filters[val] = chk
			#@model.set newAttr: @newAttr
			filters = @chartNewModel.get("filters")
			filters[val] = chk
			@chartNewModel.set filters: filters


		else if form_attr=="settings"
			val = $target.attr( 'data-value' )
			chk = !@chartNewModel.get("settings")[val]
			#@newAttr.settings[val] = chk
			#@model.set newAttr: @newAttr
			settings = @chartNewModel.get("settings")
			settings[val] = chk
			@chartNewModel.set settings: settings
			###
			if newAttr.settings['locationreport']
				@$("#locationLevel_c").prop("disabled", false)
			else
				@$("#locationLevel_c").prop("disabled", true)
			###

		else
			return true

		#console.log 'newAttr='+form_attr, @model.get("report_title"), @chartNewModel


		$inp = $target.find( 'input' )
		#console.log("checked",chk, $target, val, $inp, $inp.is(":checked"))
		setTimeout (->
			$inp.prop 'checked', chk
			return
		), 0
		false


	help: () ->
		bootbox.dialog {
			title: "Help: Create Reports",
			message: '
				<center><iframe width="640" height="360" src="https://www.youtube.com/embed/mMdOIuLorE8?rel=0" frameborder="0" allowfullscreen></iframe></center>
				<div class="panel panel-default">
					<div class="panel-heading">Questions
						<button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" disabled>
										<i class="fa fa-list-ol"></i> Select Questions <i class="fa fa-caret-down"></i>
						</button>
					</div>
					<div class="panel-body">
						<ul>
							<li>A chart will be generated for each question selected from the dropdown list</li>
							<li>Sub-Questions will be indented within the main question</li>
							<li>Selection of a numerical question will create a dropdown to select the value of X-Axis</li>
						</ul>
					</div>
				</div>
				<div class="panel panel-default">
					<div class="panel-heading">X axis</div>
					<div class="panel-body">
						<ul>
							<li>If a numeric question is selected, this box will appear</li>
							<li>Select the appropriate value you need as an X-axis parameter in the chart</li>
						</ul>
					</div>
				</div>
				<div class="panel panel-default">
					<div class="panel-heading">Filters
							<button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" disabled>
											<i class="fa fa-filter"></i><i class="fa fa-caret-down"></i>
							</button>
						</div>
						<div class="panel-body">
							<ul>
								<li>Checking the filters will apply the slected filters in the left panel to be applied for rendering charts.</li>
							</ul>
						</div>
					</div>
				</div>
				<div class="panel panel-default">
					<div class="panel-heading">Select Grouping</div>
					<div class="panel-body">
						<ul>
							<li>Renders one chart each per location based on the selected location level.</li>
							<li>\'No Grouping\' will generate one chart per question aggregating all the data</li>
						</ul>
					</div>
				</div>
				<div class="panel panel-default">
					<div class="panel-heading">Render
							<button type="button" class="btn btn-success btn-sm" disabled>
											Render
							</button>
						</div>
						<div class="panel-body">
							<ul>
								<li>Will generate the charts based on the parameters selected</li>
								<li>If modifications are required, change the parameters and click \'Render\' again</li>
							</ul>
						</div>
					</div>
				</div>
				<div class="panel panel-default">
					<div class="panel-heading">Done
							<button type="button" class="btn btn-warning btn-sm" disabled>
											Done
							</button>
						</div>
						<div class="panel-body">
							<ul>
								<li>If no more changes are required in the report, click \'Done\'</li>
								<li>Report can now be saved for loading automatically later. Report can also be downloaded as PDF/WORD/Excel</li>
							</ul>
						</div>
					</div>
				</div>
				'
		}


	qtn_template:_.template '<li><a href="#" class="small drpdwn" data-value="{{qtn_id}}" data-attr="questions" tabindex="-1">{{indent}}<input class="chkbox" type="checkbox">&nbsp; {{qtn_text}}</a></li>'

	newReport_template:_.template '
		<div class="col-md-12 col-lg-12 col-sm-12">
			<!-- QUESTIONS -->
			<div class="form-group">
					<div class="row">
						<div class="col-lg-12">
							<div class="button-group">
								<button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown">
										<i class="fa fa-list-ol"></i> Select Questions <i class="fa fa-caret-down"></i>
								</button>
								<ul id="questionName_c" class="dropdown-menu">
									<li><a href="#" class="small" data-value="option1" tabindex="-1"><input type="checkbox">&nbsp;Qtn1</a></li>
									<li><a href="#" class="small" data-value="option2" tabindex="-1"><input type="checkbox">&nbsp;Qtn2</a></li>
									<li><a href="#" class="small" data-value="option3" tabindex="-1"><input type="checkbox">&nbsp;Qtn3</a></li>
								</ul>
							</div>
						</div>
				</div>
			</div>

			<!-- Question Ends Here -->
			<!-- DATA FILTERS -->

			<div class="form-group">
					<div class="row">
						<div class="col-lg-12">
							<div class="button-group">
								<button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown">
										<i class="fa fa-filter"></i> <i class="fa fa-caret-down"></i>
								</button>
								<ul class="dropdown-menu">
									<li><a href="#" class="small drpdwn" data-attr="filters" data-value="editorFilterType" tabindex="-1"><input type="checkbox" id="editorFilterType_c">&nbsp;Apply User filter</a></li>
									<li><a href="#" class="small drpdwn" data-value="dateFilterType" data-attr="filters" tabindex="-1"><input type="checkbox" id="dateFilterType_c">&nbsp;Apply Date Filter</a></li>
									<li><a href="#" class="small drpdwn" data-value="locFilterType" data-attr="filters" tabindex="-1"><input type="checkbox" id="locFilterType_c">&nbsp;Apply Location Filter</a></li>
								</ul>
							</div>
						</div>
				</div>
			</div>

			<!-- DATA FILTERS END HERE -->
			<!-- X-AXIS VALUE -->
			<div class="form-group not_pie legendDiv">
				<p class="form-control-static"><b> X axis: </b> </p>
				<label class="sr-only" for="selectLocation">Numeric data fields use this field as X axis </label>
				<select id="legendQuestion_c" class="form-control input-sm" style="width: 10em;">
					<option value="1">Sub-County</option>
					<option value="2">Division</option><option value="3">Location</option><option value="4">Sub-location</option><option value="Type_of_water_source">Type of water source-(Page_1)</option><option value="Quality_of_water">Quality of water-(Page_1)</option><option value="Water_availability">Water availability-(Page_1)</option><option value="Ownership">Ownership of waterpoint-(Page_1)</option>
				</select>
			</div>

			<!-- X-AXIS ENDS HERE-->
			<!-- SETTINGS-->

			<div class="form-group">
				<div class="row">
					<div class="col-lg-6">
						<div class="button-group">
							<button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown">
								<i class="fa fa-cog"></i> <i class="fa fa-caret-down"></i>
							</button>
							<ul class="dropdown-menu">
								<li><a href="#" class="small drpdwn" data-value="excludenull" data-attr="settings" tabindex="-1"><input type="checkbox" id="excludenull_c">&nbsp;Exclude Non-Response Values</a></li>
								<li class="not_pie"><a href="#" class="small drpdwn" data-value="combinenumericfields" data-attr="settings" tabindex="-1"><input type="checkbox" id="combinenumericfields_c">&nbsp;Combine all numeric values into one chart</a></li>
								<!--<li><a href="#" class="small drpdwn" data-value="locationreport" data-attr="settings" tabindex="-1"><input type="checkbox" id="locationreport_c">&nbsp;Generate separate chart for each location</a></li>-->
							</ul>
						</div>
					</div>
				</div>
			</div>

			<!-- SETTINGS END HERE -->
			<!-- IF LOCATION SELECTED THEN GROUPING-->

			<div class="form-group">
				<p class="form-control-static"><b>Select Grouping:</b></p>
				<label class="sr-only" for="selectLocation">Select Grouping</label>
				<select id="locationLevel_c" class="form-control input-sm" style="width: 10em;">
								<!--<option>Sub-County</option>
								<option>Division</option>-->
				</select>
			</div>
			<!-- GROUPING enD HERES-->

			<button class="btn btn-sm btn-success" id="render" data-loading-text="<i class=\'fa fa-circle-o-notch fa-spin\'></i> Rendering">Render</button>
			<i class="editReport help-button fa fa-question-circle" id="help"></i>
			<button class="btn btn-sm editReport" id="close">Done</button>

		</div>'

}
# ChartNew ends here

# export the following globals
root = window or this
unless root.poimapper?
	root.poimapper = {}

unless root.poimapper.views?
	root.poimapper.views = {}

root.poimapper.views.ChartNew = ChartNew
