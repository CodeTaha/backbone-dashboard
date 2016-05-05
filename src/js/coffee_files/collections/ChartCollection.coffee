###
This collection contains all the charts loaded and their data

###

ChartCollection = Backbone.Collection.extend {
		model: poimapper.models.ChartModel
}

ChartReportCollection = Backbone.Collection.extend {
		model: poimapper.models.ChartReportModel
}


# export the following globals
if window.poimapper
		window.poimapper.ChartCollection = ChartCollection
		window.poimapper.ChartReportCollection = ChartReportCollection
else
		window.poimapper = {}
		window.poimapper.ChartCollection = ChartCollection
		window.poimapper.ChartReportCollection = ChartReportCollection
