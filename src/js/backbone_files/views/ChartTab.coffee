
# ChartTab starts here
ChartTab = Backbone.View.extend {
	tagName: "li"
	events: {

		#"click a label": "focus"
		#"click a.notemplate input": "change"
		#"click a.template input": "templateChange"
		"click a": "templateChange"
	}
	initialize:(options) ->
		_.bindAll this, 'render', 'appendList', 'change','createPanel', 'unrender','changeReport_Title', 'templateChange', 'focus', 'selectionChange'
		@parent = options.parent
		@chartSelectionModel = options.chartSelectionModel
		@showDataAutomatically = @parent.showDataAutomatically
		if @model.get("template")
			temp = @model.get("template_data")
			temp.template_params = @getQueryParams(temp.url)
			@model.set template_data: temp
		#console.log "ChartTab created "+@model.get("report_title")+" Template="+@model.get("template")
		#console.log "Initial data al", @showDataAutomatically, @model
		@listenTo(@chartSelectionModel, 'change:formIds', @selectionChange)
		@model.bind('remove', this.unrender)
		@model.on("change:report_title",@changeReport_Title)


	# FUNCTION: render() sets checked, loaded and appends chartPanel
	render: () ->
			@model.set checked: true
			if @model.get("newChart")
				#console.log "ChartTab->render->newChart"
				@model.set loaded: false
				@parent.$el.prepend @createPanel().render().$el
				#@chartPanel.newReport_setForm()
			else if @model.get("template")
				@model.set loaded: true
				@parent.$el.append @createPanel().render().$el
			else
				@model.set loaded: true
				@parent.$el.append @createPanel().render().$el
				@chartPanel.createChartModels()
			this


	# FUNCTION: createPanel() creates a new view of ChartPanel
	createPanel: () ->
		@chartPanel = new poimapper.views.ChartPanel(
			model: @model
			parent: this
			superParent: @parent
			chartSelectionModel: @chartSelectionModel
		)

		return @chartPanel


	# FUNCTION: appendList() Appends and <li> in the dropdown menu
	appendList:() ->
		tempclass = ''
		if @model.get("template")
			tempclass = 'template'
		else
			tempclass = 'notemplate'
		chk = 'checked'
		if !@model.get("checked")
			chk = ''

		@$el.append @li_template({
			"report_title": @model.get("report_title")
			"report_id": @model.get("report_id")
			"checked": chk
			"tempclass": tempclass
		})
		@$("i").hide()
		return this


	# FUNCTION: selectionChange() whenever formIds changes in chartSelectionModel, it loads all the templates that have the corresponding charts selected
	selectionChange:()->
		poi = @model.get("template_data").template_params.poi
		formIds = @chartSelectionModel.get("formIds")
		#console.log "model changed", @model.get("template_data").template_params.poi, @chartSelectionModel.get("formIds")
		# if autoload is false, it wont load

		if @chartSelectionModel.get("formIds").length is 0 #if no formIds selected in leftPanel, show all saved Reports
			@$el.removeClass "filtered"
			#@$el.show()
		else if @model.get("template") and !@model.get("loaded") and formIds.indexOf(poi)==-1 #if svaedReports does not belong to the selected formIds and is not loaded then hide
			@$el.addClass "filtered"
		else
			@$el.removeClass "filtered"
			#@$el.show()
			
		# remove false to load data automatically if form is selected
		if false and @showDataAutomatically and @model.get("template") and !@model.get("loaded") and formIds.indexOf(poi)!=-1
			#console.log "model changed", @model.get("template_data").template_params.poi, @chartSelectionModel.get("formIds")
			#console.log @chartSelectionModel, @model
			@templateChange()
		return


	focus: () ->
		if @model.get("loaded")
			location.hash = "#" + @model.get("report_id")
			return true
		else
			return @templateChange()

	change: () ->
		@model.set checked: !@model.get("checked")

		chk = @model.get("checked")
		self = this
		setTimeout (->
			self.$('.chkbox').prop 'checked', chk
			self.chartPanel.show_hide()
			return
		), 0
		false

	templateChange: () ->
		if @model.get("loaded")
			return @change()
		else
			#$(evt.currentTarget).parent().toggleClass('active');
			@$("i").show()
			chk = true
			self = this
			setTimeout (->

				self.$el.toggleClass('active')
				self.$('.chkbox').prop 'checked', chk
				self.render()
				self.chartPanel.fetchReport(()->
					self.$("i").hide()
					self.$el.toggleClass('active')
					self.chartPanel.createChartModels()
				)
				return
			), 0


			###
			setTimeout (->
				template_url = "#{baseUrl}app/jasper/#{t_par.poi}/#{t_par.includelocation}/#{t_par.newdata}/#{t_par.chart}/#{t_par.type}?key=" + key + "&userid="+ username + "&user_id="+ user_id + "&questions=" + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + t_par.combinenumericfields + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=json&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup
				$.ajax
					type: "GET",
					async: false,
					url: template_url#self.model.get("template_data").url,
					success: (result) ->

						self.model.set data: result
						self.render()
						self.$el.toggleClass('active')
						#console.log "Template Data=",self.model, template_url

			), 0
			###

			false

	unrender: () ->
		@$el.remove()

	# Changes the name of report title in li
	changeReport_Title: () ->
		@$("label").html @model.get("report_title")

	li_template:_.template '
			<a href="\#{{ report_id }}" class="{{tempclass}}">
				<input class="chkbox" type="checkbox" {{checked}} aria-label="...">
				<i class=\'fa fa-circle-o-notch fa-spin\'></i>
				<label>{{ report_title }}</label>
			</a>
	'

	# Helper Functions
	# getQueryParams extracts the template parameters from the url
	getQueryParams : (qs) ->
		params = undefined
		re = undefined
		tokens = undefined
		qs = qs.split('+').join(' ')
		#preqs= qs.split('?').slice(1)
		preqs = []
		preqs[0] = qs.substring(0, qs.indexOf('?'))
		preqs[1] = qs.substring(qs.indexOf('?') + 1)
		path_params = preqs[0].split('/').slice(4)
		qs = preqs[1]
		params = {}
		tokens = undefined
		re = /[?&]?([^=]+)=([^&]*)/g
		while tokens = re.exec(qs)
			params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2])
		params.poi = path_params[0]
		params.includelocation = path_params[1]
		params.newdata = path_params[2]
		params.chart = path_params[3]
		params.type = path_params[4]
		# To disable location data from templates
		params.locs = ''
		#params.levels = '' #Not sure if needed
		params.users = ''
		params.fromdate = ''
		params.todate = ''
		params
}
# ChartTab ends here
# export the following globals
root = window or this
unless root.poimapper?
	root.poimapper = {}

unless root.poimapper.views?
	root.poimapper.views = {}

root.poimapper.views.ChartTab = ChartTab
