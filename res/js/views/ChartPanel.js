var ChartPanel, root;

ChartPanel = Backbone.View.extend({
  tagName: "div",
  events: {
    "click button.close_chartPanel": "closeChartPanel",
    "click button.delete_chartPanel": "deleteTemplate",
    "click button.save_chartPanel": "saveTemplate",
    "click button.downloadReports": "downloadReports",
    "click .info-button": "showInfo",
    "click button.refresh_chartPanel": "updateSelections",
    "click button#close": "save_close",
    "click button#editReport": "editReport"
  },
  initialize: function(options) {
    _.bindAll(this, 'render', 'closeChartPanel', 'appendChart', 'createChartModels', 'show_hide', 'unrender', 'deleteTemplate', 'saveTemplate', 'changeReport_Title', 'downloadReports', 'showInfo', 'selectionChange', 'updateSelections', 'fetchReport', 'createNewReport', 'save_close', 'editReport');
    this.parent = options.parent;
    this.chartSelectionModel = options.chartSelectionModel;
    this.superParent = options.superParent;
    this.model.bind('remove', this.unrender);
    this.chartCollection = new poimapper.ChartCollection();
    this.listenTo(this.chartSelectionModel, 'change:locations change:fromDate change:toDate change:users', _.debounce(this.selectionChange, 1));
    this.chartCollection.bind('add', this.appendChart);
    return this.model.on("change:report_title", this.changeReport_Title);
  },
  render: function() {
    if (this.model.get("template")) {
      this.$el.append(this.panel_template({
        "report_title": this.model.get("report_title"),
        "report_id": this.model.get("template_data").report_id,
        "template_class": "delete_chartPanel",
        "btn_class": "danger",
        "icon_class": "trash",
        "area_label": "Delete Template"
      }));
    } else {
      this.$el.append(this.panel_template({
        "report_title": this.model.get("report_title"),
        "report_id": this.model.get("report_id"),
        "template_class": "save_chartPanel",
        "btn_class": "primary",
        "icon_class": "floppy-o",
        "area_label": "Save As Template"
      }));
    }
    this.$(".refreshing").hide();
    if (this.model.get("newChart")) {
      this.$('.chartPanelOptions').hide();
      this.$('.panel-body').prepend(this.createNewReport().render().$el);
      this.chartNew.newReport_setForm();
    }
    this.$('.refresh_chartPanel').hide();
    return this;
  },
  createNewReport: function() {
    this.chartNew = new poimapper.views.ChartNew({
      model: this.model,
      parent: this,
      superParent: this.superParent,
      chartSelectionModel: this.chartSelectionModel
    });
    return this.chartNew;
  },
  selectionChange: function() {
    return this.$('.refresh_chartPanel').show();
  },
  createChartModels: function() {
    var cdata, model, temp_data;
    while (model = this.chartCollection.first()) {
      model.destroy();
    }
    this.$('.content').empty();
    this.$('.refresh_chartPanel').hide();
    this.byLocation = parseInt(this.model.get("template_data").template_params.reportType);
    this.locationArr = [];
    if (this.model.get("template_data").template_params.combinenumericfields === "1") {
      cdata = {
        'bar': {
          'flag': false,
          'data': {}
        }
      };
      temp_data = this.model.get("data");
      $.each(temp_data, (function(_this) {
        return function(key, value) {
          if (value.numeric && value.chart_type === "bar") {
            if (!cdata.bar.flag) {
              cdata.bar.data['title'] = "Combined Numeric Fields";
              cdata.bar.data['chart_type'] = "bar";
              cdata.bar.data['no_of_pois'] = value.no_of_pois;
              cdata.bar.data['numeric'] = true;
              cdata.bar.data['chart_variables'] = {};
              cdata.bar.flag = true;
            }
            $.each(value.chart_variables, function(key2, value2) {
              return cdata.bar.data.chart_variables[key2] = value2;
            });
            return delete temp_data[key];
          }
        };
      })(this));
      if (cdata.bar.flag) {
        temp_data['CombineNumericBar'] = cdata.bar.data;
        this.model.set({
          data: temp_data
        });
      }
    }
    return $.each(this.model.get("data"), (function(_this) {
      return function(key, value) {
        var chartModel, fdata, loc_title, location, title;
        if (value.title === void 0 || value.chart_type === void 0) {
          return;
        }
        title = value.title;
        location = typeof value.location !== 'undefined' ? value.location : null;
        fdata = [];
        chartModel = new poimapper.models.ChartModel;
        chartModel.set({
          title: value.title
        });
        chartModel.set({
          chart_type: value.chart_type
        });
        chartModel.set({
          no_of_pois: value.no_of_pois
        });
        chartModel.set({
          numeric: typeof value.numeric !== 'undefined' ? value.numeric : false
        });
        chartModel.set({
          location: location
        });
        if (value.chart_variables === void 0) {
          fdata.push({
            "key": "NO DATA",
            "value": "0"
          });
        } else if (chartModel.get("numeric") === true && _this.model.get("template_data").template_params.combinenumericfields === "1") {
          fdata = value.chart_variables;
          value.title = "Combined Numeric Fields";
          chartModel.set({
            title: "Combined Numeric Fields"
          });
        } else {
          $.each(value.chart_variables, function(key2, value2) {
            var temp_key;
            temp_key = key2.split("-&");
            if (temp_key.length === 2) {
              key2 = temp_key[1];
            }
            return fdata.push({
              "key": key2,
              "value": parseInt(value2)
            });
          });
        }
        chartModel.set({
          chart_variables: fdata
        });
        if (_this.byLocation === 1) {
          loc_title = value.title.replace(/[^A-Z0-9]+/ig, "_");
          chartModel.set({
            loc_title: loc_title
          });
          if (_this.locationArr.indexOf(loc_title) === -1) {
            _this.locationArr.push(loc_title);
            _this.$('.content').append(_this.location_template({
              "title": value.title,
              "class_id": loc_title
            }));
          }
        }
        return _this.chartCollection.add(chartModel);
      };
    })(this));
  },
  appendChart: function(chartModel) {
    var chartBox, loc_title;
    chartBox = new poimapper.views.ChartBox({
      model: chartModel,
      parent: this
    });
    if (this.byLocation === 1) {
      loc_title = chartModel.get("loc_title");
      this.$('.' + loc_title).append(chartBox.render().el);
    } else {
      this.$('.content').append(chartBox.render().el);
    }
    return setTimeout(function() {
      return chartBox.createChart();
    }, 0);
  },
  updateSelections: function() {
    var self, temp;
    self = this;
    temp = this.model.get("template_data");
    temp.template_params.locs = this.chartSelectionModel.get("locations");
    temp.template_params.levels = this.chartSelectionModel.get("levels");
    temp.template_params.users = this.chartSelectionModel.get("users");
    temp.template_params.fromdate = this.chartSelectionModel.get("fromDate");
    temp.template_params.todate = this.chartSelectionModel.get("toDate");
    this.model.set({
      template_data: temp
    });
    return this.fetchReport(function() {
      return self.createChartModels();
    });
  },
  fetchReport: function(cb) {
    var key, self, t_par, template_data, template_url, user_id, username;
    this.$(".refreshing").show();
    key = this.superParent.key;
    username = this.superParent.username;
    user_id = this.superParent.user_id;
    t_par = this.model.get("template_data").template_params;
    template_url = (baseUrl + "app/jasper/" + t_par.poi + "/" + t_par.includelocation + "/" + t_par.newdata + "/" + t_par.chart + "/" + t_par.type + "?key=") + key + "&userid=" + username + "&user_id=" + user_id + "&questions=" + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + t_par.combinenumericfields + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=json" + "&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup;
    template_data = this.model.get("template_data");
    template_data.url = template_url;
    this.model.set({
      template_data: template_data
    });
    self = this;
    $.ajax({
      type: "GET",
      url: template_url,
      success: function(result) {
        self.model.set({
          data: result
        });
        self.$(".refreshing").hide();
        console.log("Refresh Data=", JSON.stringify(self.model), template_url);
        if (cb !== null) {
          return cb();
        }
      },
      error: function(result) {
        console.error("Error occured in fetching Report", error);
        this.$(".refreshing").hide();
        if (cb !== null) {
          return cb();
        }
      }
    });
    return this;
  },
  closeChartPanel: function() {
    return this.parent.change();
  },
  unrender: function() {
    return this.$el.remove();
  },
  deleteTemplate: function() {
    var self;
    self = this;
    return bootbox.confirm("Remove " + this.model.get("report_title") + " permanently from your report selections?", function(result) {
      if (result) {
        return $.ajax({
          type: "GET",
          url: baseUrl + "app/deletereport/" + self.model.get("template_data").report_id,
          headers: {
            "Content-Type": "application/json",
            userid: self.superParent.username,
            key: self.superParent.key
          },
          success: function(result) {
            bootbox.alert(result.message);
            return self.model.destroy();
          }
        });
      }
    });
  },
  saveTemplate: function() {
    var self;
    self = this;
    return bootbox.prompt({
      title: "Save Report As",
      value: this.model.get("report_title"),
      callback: function(result) {
        var json, t_par, template_url;
        if (result !== null) {
          self.model.set({
            report_title: result
          });
          t_par = self.model.get("template_data").template_params;
          template_url = (baseUrl + "app/jasper/" + t_par.poi + "/" + t_par.includelocation + "/" + t_par.newdata + "/" + t_par.chart + "/" + t_par.type + "?XXXquestions=") + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + t_par.combinenumericfields + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=" + t_par.format + "&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup;
          json = "{ \"report_name\" : \"" + self.model.get("report_title") + "\" , \"parameters\" : \"" + template_url + "\"}";
          console.log("Saving REport Template", json);
          return $.ajax({
            type: "POST",
            data: json,
            url: baseUrl + "app/savereport",
            headers: {
              "Content-Type": "application/json",
              userid: self.superParent.username,
              key: self.superParent.key
            },
            success: function(result) {
              var t;
              t = result;
              return bootbox.alert(t.message);
            }
          });
        }
      }
    });
  },
  changeReport_Title: function() {
    return this.$(".report_title").html(this.model.get("report_title"));
  },
  show_hide: function() {
    if (!this.model.get("checked")) {
      this.$el.hide();
    } else {
      this.$el.show();
    }
    return this;
  },
  showInfo: function() {
    var no_of_pois, temp_data;
    no_of_pois = 0;
    temp_data = this.model.get("data");

    /*
    		for key of temp_data
    			no_of_pois = temp_data[key].no_of_pois
    			break
     */
    return bootbox.dialog({
      title: "Details",
      message: '<ul> <li> <b>Form:</b>' + this.model.get("template_data").details.form + '</li> </ul>'
    });
  },
  downloadReports: function(evt) {
    var format, iframe, key, listenerAdded, receiver, report_type, t_par, template_url, user_id, username;
    report_type = $(evt.currentTarget).data('report_type');
    format = 'pdf';
    switch (report_type) {
      case 1:
        format = 'pdf';
        break;
      case 2:
        format = 'docx';
        break;
      case 3:
        format = 'xlsx';
    }
    key = this.superParent.key;
    username = this.superParent.username;
    user_id = this.superParent.user_id;
    t_par = this.model.get("template_data").template_params;
    template_url = (baseUrl + "app/jasper/" + t_par.poi + "/" + t_par.includelocation + "/" + t_par.newdata + "/" + t_par.chart + "/" + t_par.type + "?key=") + key + "&userid=" + username + "&user_id=" + user_id + "&questions=" + t_par.questions + "&locs=" + t_par.locs + "&levels=" + t_par.levels + "&users=" + t_par.users + "&fromdate=" + t_par.fromdate + "&todate=" + t_par.todate + "&timeinfo=" + t_par.timeinfo + "&userinfo=" + t_par.userinfo + "&legendid=" + t_par.legendid + "&reportType=" + t_par.reportType + "&locationLevels=" + t_par.locationLevels + "&combinenumericfields=" + t_par.combinenumericfields + "&timeseriestype=" + t_par.timeseriestype + "&locationLevelDataFilter=" + t_par.locationLevelDataFilter + "&orientation=" + t_par.orientation + "&rowquestionid=" + t_par.rowquestionid + "&groupid=" + t_par.groupid + "&format=" + format + "&excludenull=" + t_par.excludenull + "&subgroup=" + t_par.subgroup;
    console.log("download", template_url);
    iframe = document.createElement('iframe');
    iframe.height = 0;
    iframe.width = 0;
    iframe.src = template_url;
    receiver = function(evt) {
      if (evt.origin === window.location.origin && evt.data === "no data") {
        return bootbox.alert("no data in report");
      }
    };
    if (!listenerAdded) {
      window.addEventListener('message', receiver, false);
      listenerAdded = true;
    }
    return $("body").append(iframe);
  },
  save_close: function() {
    var self;
    self = this;
    console.log("done");
    return bootbox.confirm({
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
      callback: function(result) {
        if (result) {
          self.chartNew.$el.hide();
          self.$('#menuOptions').append('<button type=\"button\" id="editReport" class=\"btn btn-primary btn-sm chartPanelOptions\" data-report_type=\"1\" aria-label=\"Edit\"> <i class=\"fa fa-pencil\"></i> </button>');
          return self.$('.chartPanelOptions').show();
        }
      }
    });
  },
  editReport: function() {
    this.$('#editReport').remove();
    this.$('.chartPanelOptions').hide();
    return this.chartNew.$el.show();
  },
  panel_template: _.template("<div class='col-md-12 col-lg-12 col-sm-12'	id=\"{{ report_id }}\"><div class=\"panel panel-primary\"> <div class=\"panel-heading chartTitle\"> <div class='row'> <div class='col-md-8'> <h4 class='report_title'> {{ report_title }} <i class=\"info-button fa fa-info-circle\" title=\"Additional Details\"></i> <i class=\'refreshing fa fa-circle-o-notch fa-spin\'></i> </h4> </div> <div class='col-md-4' id='menuOptions'> <button type=\"button\" class=\"close close_chartPanel\" aria-label=\"Close\"> <i class=\"fa fa-times\"></i> </button> <button type=\"button\" class=\"btn btn-{{btn_class}} btn-sm {{template_class}} chartPanelOptions\" aria-label=\"{{area_label}}\"> <i class=\"fa fa-{{icon_class}}\"></i> </button> <div class=\"btn-group chartPanelOptions\" role=\"group\" aria-label=\"Download Reports\"> <button type=\"button\" class=\"btn btn-danger btn-sm downloadReports \" data-report_type=\"1\" aria-label=\"PDF\"> <i class=\"fa fa-file-pdf-o pdf\"></i> </button> <button type=\"button\" class=\"btn btn-info btn-sm downloadReports\" data-report_type=\"2\" aria-label=\"Word\"> <i class=\"fa fa-file-word-o word\"></i> </button> <button type=\"button\" class=\"btn btn-success btn-sm downloadReports \" data-report_type=\"3\" aria-label=\"Excel\"> <i class=\"fa fa-file-excel-o excel\"></i> </button> </div> <button type=\"button\" class=\"btn btn-primary btn-sm refresh_chartPanel chartPanelOptions\" aria-label=\"Refresh\"> <i class=\"fa fa-refresh\"></i> </button> </div> </div> </div> <div class=\"panel-body\"> <div class=\"content\"></div> </div> </div></div>"),
  location_template: _.template("<div class='col-md-12 col-lg-12 col-sm-12'\"><div class=\"panel panel-info\"> <div class=\"panel-heading chartTitle\"> <h5 class='question_title'> <center><b> {{ title }} </center></b> </h5> </div> <div class=\"panel-body {{ class_id }}\"></div> </div></div>")
});

root = window || this;

if (root.poimapper == null) {
  root.poimapper = {};
}

if (root.poimapper.views == null) {
  root.poimapper.views = {};
}

root.poimapper.views.ChartPanel = ChartPanel;

//# sourceMappingURL=../maps/views/ChartPanel.js.map
