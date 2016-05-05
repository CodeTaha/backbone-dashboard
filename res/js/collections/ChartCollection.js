
/*
This collection contains all the charts loaded and their data
 */
var ChartCollection, ChartReportCollection;

ChartCollection = Backbone.Collection.extend({
  model: poimapper.models.ChartModel
});

ChartReportCollection = Backbone.Collection.extend({
  model: poimapper.models.ChartReportModel
});

if (window.poimapper) {
  window.poimapper.ChartCollection = ChartCollection;
  window.poimapper.ChartReportCollection = ChartReportCollection;
} else {
  window.poimapper = {};
  window.poimapper.ChartCollection = ChartCollection;
  window.poimapper.ChartReportCollection = ChartReportCollection;
}

//# sourceMappingURL=../maps/collections/ChartCollection.js.map
