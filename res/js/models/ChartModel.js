
/*
This model represents all the charts created in ChartView and has one to one mapping with ChartBox
 */
var ChartModel, ChartNewModel, ChartReportModel, ChartSelectionModel;

ChartModel = Backbone.Model.extend({
  defaults: {
    title: "Chart Title",
    no_of_pois: "53",
    chart_type: "bar",
    location: null,
    chart_variables: [
      {
        "key": "All year round",
        "value": 16
      }, {
        "key": "No response",
        "value": 6
      }, {
        "key": "Seasonal",
        "value": 29
      }
    ],
    numeric: false
  }
});

ChartReportModel = Backbone.Model.extend({
  defaults: {
    report_title: "Report Title",
    report_id: null,
    checked: false,
    template: false,
    form_id: null,
    loaded: false,
    data: null,
    template_data: null,
    newChart: false
  }
});

ChartSelectionModel = Backbone.Model.extend({
  defaults: {
    formIds: [],
    locations: [],
    users: [],
    fromDate: "",
    toDate: "",
    levels: []
  }
});

ChartNewModel = Backbone.Model.extend({
  defaults: {
    report_title: null,
    questions: null,
    filters: null,
    settings: null
  }
});

if (window.poimapper == null) {
  window.poimapper = {};
}

if (window.poimapper.models == null) {
  window.poimapper.models = {};
}

window.poimapper.models.ChartModel = ChartModel;

window.poimapper.models.ChartReportModel = ChartReportModel;

window.poimapper.models.ChartSelectionModel = ChartSelectionModel;

window.poimapper.models.ChartNewModel = ChartNewModel;

//# sourceMappingURL=../maps/models/ChartModel.js.map
