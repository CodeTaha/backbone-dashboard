###
This model represents all the charts created in ChartView and has one to one mapping with ChartBox
###

ChartModel = Backbone.Model.extend {
	defaults: {
		title: "Chart Title", # chart Title
		no_of_pois: "53", # Number of Data Points
		chart_type: "bar", # bar/pie/area/line etc
		location: null, # if charts needs to be grouped by locations
		#chart_variables: {"All year round": "16","No response": "6","Seasonal": "29"}
		chart_variables:[{"key":"All year round","value":16},{"key":"No response","value":6},{"key":"Seasonal","value":29}],
		numeric: false,
	}

}

ChartReportModel = Backbone.Model.extend {
	defaults: {
		report_title: "Report Title", # chart Title
		report_id: null,
		checked: false, # Whether collection is displayed or not
		template: false, # if template then true
		form_id: null, # for new Charts
		loaded: false, # is when data is loaded for the first time
		data: null
		template_data: null, # if charts needs to be grouped by locations
		# Variables if its a new chart
		newChart: false, # if chart is new
	}

}

ChartSelectionModel = Backbone.Model.extend {
	defaults: {
		formIds: [],
		locations: [],
		users: [],
		fromDate: "",
		toDate: "",
		levels: []

	}
}

ChartNewModel = Backbone.Model.extend {
	defaults: {
		report_title: null,
		questions: null,
		filters: null,
		settings:null,
	}
}


# export the following globals
unless window.poimapper?
	window.poimapper = {}

unless window.poimapper.models?
	window.poimapper.models = {}

window.poimapper.models.ChartModel = ChartModel
window.poimapper.models.ChartReportModel = ChartReportModel
window.poimapper.models.ChartSelectionModel = ChartSelectionModel
window.poimapper.models.ChartNewModel = ChartNewModel
