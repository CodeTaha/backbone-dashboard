var ChartView, root;

ChartView = Backbone.View.extend({
  el: "#chartArea",
  events: {},
  initialize: function(options) {
    _.bindAll(this, 'render', 'renderReport', 'getTemplates', 'fetchTemplateDetails', 'renderTemplates', 'callChartTab', 'updateSelections', 'createNewChart');
    this.username = options.username;
    this.user_id = options.user_id;
    this.key = options.key;
    this.showDataAutomatically = options.showDataAutomatically;
    this.$el.empty();
    this.counter = 1;
    this.$el.hide();
    this.templates = [];
    this.chartSelectionModel = new poimapper.models.ChartSelectionModel();
    this.chartReportCollection = new poimapper.ChartCollection();
    this.chartReportCollection.bind('add', this.callChartTab);
    this.$el.append(this.modal_template());
    return $("#chartpoitypes").append('<li class="dropdown-header templateheader">Saved Reports</li>');
  },
  render: function() {
    var readyStateCheckInterval;
    this.getTemplates();
    $("#chartTab").show();
    return readyStateCheckInterval = setInterval(function() {
      var showVid;
      if (document.readyState === "complete") {
        clearInterval(readyStateCheckInterval);
        showVid = (window.clientPersistModel.get("chartVid") === "true" ? true : false);
        if (showVid) {
          bootbox.dialog({
            title: "New Feature: Tutorial to use Charts",
            message: '<center><iframe width="640" height="360" src="https://www.youtube.com/embed/mMdOIuLorE8?rel=0" frameborder="0" allowfullscreen></iframe></center>',
            buttons: {
              danger: {
                label: "Close",
                className: "btn-primary",
                callback: function() {
                  return window.clientPersistModel.set({
                    chartVid: "false"
                  });
                }
              }
            }
          });
          return window.clientPersistModel.set({
            chartVid: "false"
          });
        }
      }
    }, 10);
  },
  createNewChart: function() {
    var form, options, self, therealname;
    $("#chartButton").trigger("click");
    form = root.formCollection;
    self = this;
    if (form.length === 0) {
      return bootbox.alert("Please wait for the forms to load");
    } else {
      therealname = {};
      options = [];
      form.each(function(model) {
        if (model.get("type") !== "TABLE") {
          return _.each(model.get("questionPage"), function(page) {
            return _.each(page.question, function(question) {
              var tm;
              if (question.type === "TableQuestion" && question.inVisible === false) {
                tm = window.formCollection.findWhere({
                  "ref": question.table.columns.relation[0].ref
                });
                return therealname[tm.id] = question.text;
              }
            });
          });
        }
      });
      form.each(function(model) {
        if (!model.get("isChild") && model.get("type") === "POI") {
          return options.push({
            "name": model.get("name"),
            "value": model.get("id")
          });
        } else if (model.get("isChild") && model.get("type") === "POI") {
          return options.push({
            "name": "Subform: " + (model.get("name")),
            "value": model.get("id")
          });
        } else if (model.get("isChild") && model.get("type") === "TABLE") {
          if (therealname[model.id] !== undefined) {
            return options.push({
              "name": "Table: " + (model.get("name")),
              "value": model.get("id")
            });
          }
        }
      });
      bootbox.dialog({
        title: "Create a New Report",
        message: '<div class="row">  ' + '<div class="col-md-12"> ' + '<form class="form-horizontal"> ' + '<div class="form-group"> ' + '<label class="col-md-4 control-label" for="report_title">Report Name</label> ' + '<div class="col-md-4"> ' + '<input type="text" id="report_title" name="report_title" type="text" value="' + "New Report-" + this.counter + '" placeholder="Enter Report Name" class="form-control input-md"/>' + '</div> ' + '</div> ' + '<div class="form-group"> ' + '<label class="col-md-4 control-label" for="form_id">Select Form</label> ' + '<div class="col-md-4"> ' + '<select id="form_id" name="form_id" type="text" placeholder="Select Form" class="form-control input-md"></select>' + '</div> ' + '</div> ' + '<div class="form-group"> ' + '<label class="col-md-4 control-label" for="chart_type">Type of Chart</label> ' + '<div class="col-md-4"> ' + '<select id="chart_type" name="chart_type" type="text" placeholder="Select chart type" class="form-control input-md">' + '<option value="0">Bar Chart</option>' + '<option value="3">Pie Chart</option>' + '</select>' + '</div> ' + '</div> ' + '</form> </div>  </div>',
        buttons: {
          success: {
            label: "Define Report",
            className: "btn-success",
            callback: function() {
              var chartReportModel;
              chartReportModel = new poimapper.models.ChartReportModel;
              chartReportModel.set({
                form_id: $("#form_id").val()
              });
              chartReportModel.set({
                template: false
              });
              chartReportModel.set({
                newChart: true
              });
              chartReportModel.set({
                report_title: $("#report_title").val()
              });
              chartReportModel.set({
                template_data: {
                  "url": "",
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
                  "details": {
                    "form": $.grep(options, function(e) {
                      return e.value === $('#form_id').val();
                    })[0].name
                  }
                }
              });
              chartReportModel.set({
                report_id: (chartReportModel.get("report_title") + self.counter).replace(/[^A-Z0-9]+/ig, "_")
              });
              self.chartReportCollection.add(chartReportModel);
              return self.counter++;
            }
          },
          cancel: {
            label: "cancel",
            className: "btn",
            callback: function() {}
          }
        }
      });
      return $.each(options, function(index, opt) {
        return $("#form_id").append(new Option(opt.name, opt.value), null);
      });
    }
  },
  callChartTab: function(chartReportModel) {
    var chartTab;
    chartTab = new poimapper.views.ChartTab({
      model: chartReportModel,
      parent: this,
      chartSelectionModel: this.chartSelectionModel
    });
    this.counter++;
    if (chartReportModel.get("template")) {
      $("#chartpoitypes").append(chartTab.appendList().$el);
    } else {
      chartTab.render();
      $("#chartpoitypes .templateheader").before(chartTab.appendList().$el);
    }
    return this;
  },
  renderReport: function(report_data) {
    var chartReportModel, form, self;
    self = this;
    chartReportModel = new poimapper.models.ChartReportModel;
    chartReportModel.set({
      report_title: "Reporttest" + this.counter
    });
    chartReportModel.set({
      template: false
    });
    form = (root.formCollection.get(report_data.template_params.poi) != null ? root.formCollection.get(report_data.template_params.poi) : '');
    report_data.details = {};
    report_data.details.form = form;
    chartReportModel.set({
      report_id: chartReportModel.get("report_title").replace(/[^A-Z0-9]+/ig, "_")
    });
    if (report_data.data === void 0) {
      setTimeout(function() {
        var callback;
        callback = function(data, status) {
          chartReportModel.set({
            template_data: report_data
          });
          chartReportModel.set({
            data: data
          });
          return self.chartReportCollection.add(chartReportModel);
        };
        return $.get(report_data.url, callback);
      });
    } else {
      chartReportModel.set({
        data: report_data.data
      });
      delete report_data.data;
      chartReportModel.set({
        template_data: report_data
      });
      this.chartReportCollection.add(chartReportModel);
    }
    return this.counter++;
  },
  renderTemplates: function(element) {
    var self;
    self = this;
    $.ajax({
      type: "GET",
      async: false,
      url: "/json/app/applytemplate/" + element.report_id,
      headers: {
        "Content-Type": "application/json",
        userid: self.username,
        key: self.key
      },
      success: function(result) {
        var chartReportModel;
        element['url'] = result.message;
        chartReportModel = new poimapper.models.ChartReportModel;
        chartReportModel.set({
          report_title: element.report_name
        });
        chartReportModel.set({
          template: true
        });
        chartReportModel.set({
          template_data: element
        });
        chartReportModel.set({
          report_id: (chartReportModel.get("report_title") + this.counter).replace(/[^A-Z0-9]+/ig, "_")
        });
        self.chartReportCollection.add(chartReportModel);
        return this.counter++;
      }
    });
    return this;
  },
  getTemplates: function() {
    var self;
    self = this;
    return $.ajax({
      type: "GET",
      url: "/json/app/reports/" + this.user_id,
      headers: {
        "Content-Type": "application/json",
        userid: this.username,
        key: this.key
      },
      success: function(results) {
        var i, results1;
        i = 0;
        results1 = [];
        while (i < results.length) {
          self.fetchTemplateDetails(results[i]);
          results1.push(i++);
        }
        return results1;
      }
    });
  },
  fetchTemplateDetails: function(element) {
    var self;
    self = this;
    return $.ajax({
      type: "GET",
      url: baseUrl + "app/templatedetails/" + element.report_id,
      headers: {
        "Content-Type": "application/json",
        userid: userName,
        key: pwrd
      },
      success: function(result) {
        if (result[0].format === 'json') {
          element['details'] = result[0];
          self.templates.push(element);
          return self.renderTemplates(element);
        }
      }
    });
  },
  updateSelections: function(formIds, locations, users, fromDate, toDate, levels) {
    var date, form, temp_model;
    form = root.formCollection;
    temp_model = new poimapper.models.ChartSelectionModel();
    if (!_.isNaN(fromDate)) {
      date = new Date(fromDate);
      fromDate = date.getFullYear() + '-' + ('0' + (date.getMonth() + 1)).slice(-2) + '-' + ('0' + date.getDate()).slice(-2);
      temp_model.set({
        fromDate: fromDate
      });
    }
    if (!_.isNaN(toDate)) {
      date = new Date(toDate);
      toDate = date.getFullYear() + '-' + ('0' + (date.getMonth() + 1)).slice(-2) + '-' + ('0' + date.getDate()).slice(-2);
      temp_model.set({
        toDate: toDate
      });
    }
    temp_model.set({
      formIds: formIds
    });
    temp_model.set({
      locations: locations
    });
    temp_model.set({
      users: users
    });
    temp_model.set({
      levels: levels
    });
    return this.chartSelectionModel.set(temp_model.toJSON());
  },
  panel_template: _.template("<div class='col-md-4 col-lg-4 col-sm-6'><div class=\"panel panel-primary chartBox\"> <div class=\"panel-heading chartTitle\"> {{ graph_title }} <button type='button' class='btn btn-xs btn-default col-md-2' aria-label='Maximize' style='float:right;' data-target='#myModal' data-toggle='modal' data-id='{{data_id}}'> <span class='glyphicon glyphicon-zoom-in' aria-hidden='true'></span> </button> </div> <div class=\"panel-body {{chart_type}}\" id=\"viz_{{ counter }}\"></div> </div></div>"),
  modal_template: _.template('<div class="modal fade" id="maxModal" tabindex="-1" role="dialog" aria-labelledby="maxModalLabel"> <div class="modal-dialog modal-lg" id="chart-modal-content" role="document"> <div class="modal-content"> <div class="modal-header"> <button type="button" class="close" data-dismiss="modal" aria-label="Close">close<i class="fa fa-times"></i></button> <h4 class="modal-title" id="maxModalLabel">Chart title</h4> </div> <div class="modal-body" id="max_chart"> Chart goes here </div> </div> </div> </div>')
});

root = window || this;

if (root.poimapper == null) {
  root.poimapper = {};
}

if (root.poimapper.views == null) {
  root.poimapper.views = {};
}

root.poimapper.views.ChartView = ChartView;

//# sourceMappingURL=../maps/views/ChartView.js.map
