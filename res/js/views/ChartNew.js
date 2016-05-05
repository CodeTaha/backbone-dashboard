var ChartNew, root;

ChartNew = Backbone.View.extend({
  tagName: "div",
  className: "form-inline ChartNew",
  events: {
    "change #legendQuestion_c": "newReport_updateGrouping",
    "click a.drpdwn": "change",
    "click button#render": "renderReport",
    "click #help": "help"
  },
  initialize: function(options) {
    var filters, questions, settings;
    _.bindAll(this, 'render', 'addLegendSelectOptions', 'newReport_setForm', 'newReport_changeChartType', 'newReport_addQuestions', 'newReport_addLegendSelectAreaLine', 'newReport_addLegendSelectBarAreaLine', 'newReport_addLegendSelectPie', 'change', 'newReport_updateGrouping', 'renderReport', 'stopLoading', 'help');
    this.parent = options.parent;
    this.chartSelectionModel = options.chartSelectionModel;
    this.superParent = options.superParent;
    this.model = options.model;
    this.isNumericField = 0;
    this.chartNewModel = new poimapper.models.ChartNewModel();
    questions = {};
    filters = {
      "editorFilterType": false,
      "dateFilterType": false,
      "locFilterType": false
    };
    settings = {
      "excludenull": false,
      "combinenumericfields": false
    };
    this.chartNewModel.set({
      report_title: this.model.get("report_title")
    });
    this.chartNewModel.set({
      questions: {}
    });
    this.chartNewModel.set({
      filters: filters
    });
    return this.chartNewModel.set({
      settings: settings
    });
  },
  render: function() {
    this.$el.append(this.newReport_template({}));
    return this;
  },
  newReport_setForm: function() {
    this.chartId = Number(this.model.get("template_data").template_params.chart);
    if (this.chartId === 3) {
      this.$("#legendQuestion_c").val("0");
      this.$(".not_pie").hide();
    }
    this.newReport_updateGrouping();
    this.$(".legendDiv").hide();
    this.$("#close").prop("disabled", true);
    return this.newReport_changeChartType();
  },
  newReport_updateGrouping: function() {
    var chartType, i, legendQuestionid, value_id;
    chartType = this.model.get("template_data").template_params.chart;
    legendQuestionid = Number(this.$("#legendQuestion_c").val());
    this.$("#locationLevel_c").empty();
    if (this.chartId === 3 || this.isNumericField === 0) {
      i = 0;
      while (i < locationLabels.length) {
        if (locationLabels[i] !== null && locationLabels[i] !== "Location 1" && locationLabels[i] !== "Location 2" && locationLabels[i] !== "Location 3" && locationLabels[i] !== "Location 4" && locationLabels[i] !== "null") {
          this.$("#locationLevel_c").append(new Option(locationLabels[i], i + 1), null);
        }
        i++;
      }
    } else if (legendQuestionid === 1 || legendQuestionid === 2 || legendQuestionid === 3 || legendQuestionid === 4) {
      i = 0;
      while (i < window.locationLabels.length) {
        value_id = i + 1;
        if (value_id < legendQuestionid) {
          if (window.locationLabels !== null && window.locationLabels[i] !== "Location 1" && window.locationLabels[i] !== "Location 2" && window.locationLabels[i] !== "Location 3" && window.locationLabels[i] !== "Location 4" && window.locationLabels[i] !== "null") {
            this.$("#locationLevel_c").append(new Option(window.locationLabels[i], i + 1), null);
          }
        }
        i++;
      }
    } else {
      this.$("#locationLevel_c").empty();
      i = 0;
      while (i < window.locationLabels.length) {
        if (window.locationLabels !== null && window.locationLabels[i] !== "Location 1" && window.locationLabels[i] !== "Location 2" && window.locationLabels[i] !== "Location 3" && window.locationLabels[i] !== "Location 4" && window.locationLabels[i] !== "null") {
          this.$("#locationLevel_c").append(new Option(window.locationLabels[i], i + 1), null);
        }
        i++;
      }
    }
    return this.$("#locationLevel_c").prepend(new Option("No Grouping", 0), null);
  },
  newReport_changeChartType: function() {
    var pages, x, y;
    this.qSelect = Number(this.model.get("form_id"));
    this.srcSelect = this.$("#questionName_c");
    this.srcSelect.empty();
    this.legendSelect = this.$("#legendQuestion_c");
    this.legendSelect.empty();
    this.formId = this.model.get("form_id");
    this.formModel = window.formCollection.get(this.formId);
    pages = this.formModel.get("questionPage");
    this.page = [];
    if (!this.formModel.get("hasLocationHierarchy")) {
      this.$("#locationLevel_c").parent().hide();
    }
    if (this.formModel.get("type") === "TABLE") {
      this.page = this.formModel.get("question");
    } else if (this.formModel.get("type") === 'POI' || this.formModel.get("type") === 'AREA' || this.formModel.get("type") === 'ROUTE') {
      x = 0;
      while (x < pages.length) {
        y = 0;
        while (y < pages[x].question.length) {
          pages[x].question[y]["page_number"] = x;
          this.page.push(pages[x].question[y]);
          y++;
        }
        x++;
      }
    }
    return this.addLegendSelectOptions();
  },
  addLegendSelectOptions: function() {
    if (this.chartId === 1 || this.chartId === 2) {
      this.newReport_addLegendSelectAreaLine();
    }
    if (this.chartId === 0 || this.chartId === 1 || this.chartId === 2) {
      this.newReport_addLegendSelectBarAreaLine();
    }
    if (this.chartId === 3) {
      return this.newReport_addLegendSelectPie();
    }
  },
  newReport_addLegendSelectAreaLine: function() {
    this.legendSelect.append(new Option("Day when updated", "modifiedday"), null);
    this.legendSelect.append(new Option("Week when updated", "modifiedweek"), null);
    this.legendSelect.append(new Option("Month when updated", "modifiedmonth"), null);
    this.legendSelect.append(new Option("Year	when updated", "modifiedyear"), null);
    this.legendSelect.append(new Option("Time of day when updated (24 hours)", "modifieddaytime"), null);
    return this.legendSelect.append(new Option("Modified Time", "modified"), null);
  },
  newReport_addLegendSelectBarAreaLine: function() {
    var i, j, opt, qn, results;
    i = 0;
    if (this.formModel.get("type") === 'POI' || this.formModel.get("type") === 'AREA' || this.formModel.get("type") === 'ROUTE') {
      while (i < locationLabels.length) {
        if (locationLabels[i] !== null && locationLabels[i] !== "Location 1" && locationLabels[i] !== "Location 2" && locationLabels[i] !== "Location 3" && locationLabels[i] !== "Location 4" && locationLabels[i] !== "null") {
          if (this.chartId === 0) {
            this.legendSelect.append(new Option(locationLabels[i], i + 1), null);
          }
        } else {

        }
        i++;
      }
    }
    j = 0;
    results = [];
    while (j < this.page.length) {
      qn = this.page[j];
      if (qn.type === "IdQuestion" || qn.type === "PicturesQuestion" || qn.type === "Part_of_Question" || qn.type === "TimeQuestion" || qn.type === "TableQuestion" || qn.type === "Label" || qn.type === "HeaderQuestion" || qn.id === "phoneEditTime" || qn.id === "portalEditTime" || qn.id === "portalEditEntry" || qn.id === "Location1" || qn.id === "Location2" || qn.id === "Location3" || qn.id === "Location4" || qn.type === "GPSQuestion") {
        if (qn.id === "user_id") {

        } else {
          j++;
          continue;
        }
      } else {
        if ((qn.type === "BooleanQuestion" || qn.type === "SelectOneQuestion" || qn.type === "SelectMultipleQuestion" || qn.type === "StatusQuestion" || (qn.validationlist !== void 0 && qn.validationlist.length > 0)) && this.chartId === 0 && !qn.inVisible) {
          this.legendSelect.append(new Option(qn.text + "-(Page_" + Number(qn.page_number + 1) + ")", qn.id), null);
        }
        if (qn.type !== "NameQuestion") {
          if (qn.type !== "SkipQuestion") {
            if (this.chartId === 0 || this.chartId === 1 || this.chartId === 2) {
              if ((qn.type === "IntQuestion" || qn.type === "FloatQuestion") || (!qn.inVisible && (qn.text === "Count" || qn.text === "count" || qn.id === "countQuestion"))) {
                if (this.formModel.get("type") === "TABLE") {
                  this.newReport_addQuestions(qn.text, qn.id, 'yes');
                } else {
                  this.newReport_addQuestions(qn.text + "-(Pages_" + Number(qn.page_number + 1) + ")", qn.id, 'yes');
                }
              } else {
                opt = new Option(qn.text + "-(Page_" + Number(qn.page_number + 1) + ")", qn.id);
                $(opt).attr('isnumber', 'no');
                if ((qn.type === "BooleanQuestion" || qn.type === "SelectOneQuestion" || qn.type === "SelectMultipleQuestion" || qn.type === "StatusQuestion" || (qn.validationlist !== void 0 && qn.validationlist.length > 0) || qn.type === "IntQuestion" || qn.type === "FloatQuestion") && !qn.inVisible) {
                  if (this.formModel.get("type") === "TABLE") {
                    this.newReport_addQuestions(qn.text, qn.id, 'no');
                  } else {
                    this.newReport_addQuestions(qn.text + "-(Page_" + Number(qn.page_number + 1) + ")", qn.id, 'no');
                  }
                }
              }
            } else {
              if ((qn.type === "BooleanQuestion" || qn.type === "SelectOneQuestion" || qn.type === "SelectMultipleQuestion" || qn.type === "StatusQuestion" || (qn.validationlist !== void 0 && qn.validationlist.length > 0) || qn.type === "IntQuestion" || qn.type === "FloatQuestion") && !qn.inVisible) {
                if (this.formModel.get("type") === "TABLE") {
                  this.newReport_addQuestions(qn.text, qn.id, null);
                } else {
                  this.newReport_addQuestions(qn.text + "-(Page_" + Number(qn.page_number + 1) + ")", qn.id, null);
                }
              }
            }
          }
          if ((qn.triggerValues != null) && !qn.inVisible) {
            this.addSubQuestions(qn, 1);
          }
        }
      }
      results.push(j++);
    }
    return results;
  },
  newReport_addLegendSelectPie: function() {
    var j, qn, results;
    j = 0;
    results = [];
    while (j < this.page.length) {
      qn = this.page[j];
      if (qn.inVisible || qn.type === "IdQuestion" || qn.type === "PicturesQuestion" || qn.type === "Part_of_Question" || qn.type === "TimeQuestion" || qn.type === "TableQuestion" || qn.type === "Label" || qn.type === "HeaderQuestion" || qn.id === "phoneEditTime" || qn.id === "portalEditTime" || qn.id === "portalEditEntry" || qn.id === "Location1" || qn.id === "Location2" || qn.id === "Location3" || qn.id === "Location4" || qn.type === "GPSQuestion" || qn.type === "ValidationRuleQuestion" || qn.type === "FileQuestion") {
        j++;
        continue;
      } else {
        if (qn.type === "BooleanQuestion" || qn.type === "SelectOneQuestion" || qn.type === "SelectMultipleQuestion" || qn.type === "SkipQuestion" || qn.type === "StatusQuestion" || (qn.validationlist !== void 0 && qn.validationlist.length > 0)) {
          if (qn.type !== "SkipQuestion") {
            this.newReport_addQuestions(qn.text + "-(Page_" + Number(qn.page_number + 1) + ")", qn.id, null);
          }
          if (qn.triggerValues != null) {
            this.addSubQuestions(qn, 1);
          }
        }
      }
      results.push(j++);
    }
    return results;
  },
  addSubQuestions: function(qn, rowandcolumn) {
    var k, l, len, len1, ref, ref1, subQs, triggerValue;
    ref = qn.triggerValues.triggerValue;
    for (k = 0, len = ref.length; k < len; k++) {
      triggerValue = ref[k];
      if (triggerValue.action.subQuestions != null) {
        ref1 = triggerValue.action.subQuestions.question;
        for (l = 0, len1 = ref1.length; l < len1; l++) {
          subQs = ref1[l];
          if (subQs.text !== void 0) {
            switch (this.chartId) {
              case -1:
                return;
              case -2:
                return;
              case 0:
              case 1:
              case 2:
                if (subQs.type === "IntQuestion" || subQs.type === "FloatQuestion" || subQs.type === "SelectOneQuestion" || subQs.type === "SelectMultipleQuestion" || subQs.type === "BooleanQuestion") {
                  if (subQs.type === "IntQuestion" || subQs.type === "FloatQuestion") {
                    this.newReport_addQuestions(subQs.text, subQs.id, 'yes', true);
                  } else {
                    this.newReport_addQuestions(subQs.text, subQs.id, 'no', true);
                  }
                }
                break;
              case 3:
                if (subQs.type === "SelectOneQuestion" || subQs.type === "SelectMultipleQuestion" || subQs.type === "BooleanQuestion") {
                  this.newReport_addQuestions(subQs.text, subQs.id, null, true);
                }
            }
          }
        }
        if (subQs.triggerValues != null) {
          this.addSubQuestions(subQs, rowandcolumn);
        }
      }
    }
  },
  newReport_addQuestions: function(qtn_text, qtn_id, isnumber, isSubQtn) {
    var indent, obj, questions;
    if (isSubQtn == null) {
      isSubQtn = false;
    }
    obj = {
      "qtn_text": qtn_text,
      "qtn_id": qtn_id,
      "isnumber": isnumber,
      "checked": false
    };
    indent = "";
    if (isSubQtn) {
      indent = "&nbsp; &nbsp;";
    }
    if (isnumber === 'yes') {
      qtn_text = qtn_text + "(numeric)";
    }
    questions = this.chartNewModel.get("questions");
    questions[qtn_id] = obj;
    this.chartNewModel.set({
      questions: questions
    });
    return this.srcSelect.append(this.qtn_template({
      "qtn_id": qtn_id,
      "qtn_text": qtn_text,
      "indent": indent
    }));
  },
  renderReport: function() {
    var self, template_data, template_params;
    this.$("#render").button('loading');
    self = this;
    this.params = {};
    this.params.fieldsToBeReported = "";
    this.params.hasNumericFields = false;
    $.each(this.chartNewModel.get("questions"), (function(_this) {
      return function(key, value) {
        if (value.checked === true) {
          if (_this.chartId === 0 || _this.chartId === 1 || _this.chartId === 2) {
            if (value.isnumber === "yes") {
              _this.params.hasNumericFields = true;
            }
          }
          if (_this.params.fieldsToBeReported === "") {
            return _this.params.fieldsToBeReported += "" + value.qtn_id;
          } else {
            return _this.params.fieldsToBeReported += "," + value.qtn_id;
          }
        }
      };
    })(this));
    this.params.fieldsToBeReported += "";
    this.params.combinenumericfields = (this.chartNewModel.get("settings").combinenumericfields ? "1" : "0");
    this.params.excludenull = (this.chartNewModel.get("settings").excludenull ? "1" : "0");
    this.params.editorFilterType = (this.chartNewModel.get("filters").editorFilterType ? "1" : "0");
    this.params.dateFilterType = (this.chartNewModel.get("filters").dateFilterType ? "1" : "0");
    this.params.locFilterType = (this.chartNewModel.get("filters").locFilterType ? "1" : "0");
    this.params.legendid = this.$("#legendQuestion_c").val();
    console.log("legend", this.$("#legendQuestion_c").val(), this.$("#legendQuestion_c :selected").text());
    this.params.reportType = "0";
    this.params.locationLevels = (this.$("#locationLevel_c").val() === null ? "0" : this.$("#locationLevel_c").val());
    if (this.params.locationLevels !== "0") {
      this.params.reportType = "1";
    }
    this.params.includeUsers = "0";
    this.params.includelocation = "0";
    this.params.locationLevelDataFilter = "";
    this.params.orientation = "1";
    this.params.format = "json";
    this.params.subgroup = "";
    this.params.includetimestamp = "0";
    this.params.newdata = "1";
    this.params.type = "SUM";
    this.params.rowquestion = "";
    this.params.timeseriestype = "";
    if (this.chartId === 1 || this.chartId === 2) {
      if (this.params.legendid === "modifiedday") {
        this.params.legendid = "modified";
        this.params.timeseriestype = "DAY";
      } else if (this.params.legendid === "modifiedweek") {
        this.params.legendid = "modified";
        this.params.timeseriestype = "WEEK";
      } else if (this.params.legendid === "modifiedmonth") {
        this.params.legendid = "modified";
        this.params.timeseriestype = "MONTH";
      } else if (this.params.legendid === "modifiedyear") {
        this.params.legendid = "modified";
        this.params.timeseriestype = "YEAR";
      } else if (this.params.legendid === "modifieddaytime") {
        this.params.legendid = "modified";
        this.params.timeseriestype = "TIME";
      }
    }
    template_data = this.model.get("template_data");
    template_params = template_data.template_params;
    if (this.params.fieldsToBeReported === "") {
      bootbox.alert("Please select a question");
      this.stopLoading();
      return;
    } else {
      template_params.questions = this.params.fieldsToBeReported;
      template_params.newdata = this.params.newdata;
      template_params.includelocation = this.params.includelocation;
      template_params.type = this.params.type;
      template_params.includetimestamp = this.params.includetimestamp;
      template_params.includeUsers = this.params.includeUsers;
      template_params.legendid = this.params.legendid;
      template_params.reportType = this.params.reportType;
      template_params.locationLevels = this.params.locationLevels;
      template_params.combinenumericfields = this.params.combinenumericfields;
      template_params.timeseriestype = this.params.timeseriestype;
      template_params.locationLevelDataFilter = this.params.locationLevelDataFilter;
      template_params.orientation = this.params.orientation;
      template_params.format = this.params.format;
      template_params.excludenull = this.params.excludenull;
      template_params.subgroup = this.params.subgroup;
    }
    if (this.params.dateFilterType === "1") {
      template_params.fromdate = this.chartSelectionModel.get("fromDate");
      template_params.todate = this.chartSelectionModel.get("toDate");
    } else {
      template_params.fromdate = "";
      template_params.todate = "";
    }
    if (this.params.editorFilterType === "1") {
      template_params.users = this.chartSelectionModel.get("users");
    } else {
      template_params.users = "";
    }
    if (this.params.locFilterType === "1") {
      template_params.locs = this.chartSelectionModel.get("locations");
      template_params.levels = this.chartSelectionModel.get("levels");
    } else {
      template_params.locs = "";
      template_params.levels = "";
    }
    template_data.template_params = template_params;
    this.model.set({
      template_data: template_data
    });
    if (!this.model.get("loaded")) {
      this.$("#close").addClass("btn-warning");
      this.$("#close").prop("disabled", false);
    }
    this.model.set({
      loaded: true
    });
    return setTimeout(function() {
      return self.parent.fetchReport(function() {
        self.parent.createChartModels();
        return self.stopLoading();
      });
    }, 0);
  },
  stopLoading: function() {
    return this.$("#render").button('reset');
  },
  change: function(evt) {
    var $inp, $target, chk, filters, form_attr, questions, self, settings, val;
    self = this;
    $target = $(evt.currentTarget);
    form_attr = $target.attr('data-attr');
    if (form_attr === "questions") {
      val = $target.attr('data-value');
      chk = !this.chartNewModel.get("questions")[val].checked;
      questions = this.chartNewModel.get("questions");
      questions[val].checked = chk;
      this.chartNewModel.set({
        questions: questions
      });
      if (this.chartNewModel.get("questions")[val].isnumber === "yes") {
        if (chk) {
          this.isNumericField++;
        } else {
          this.isNumericField--;
        }
        if (this.isNumericField > 0) {
          this.$(".legendDiv").show();
          this.newReport_updateGrouping();
        } else {
          this.$(".legendDiv").hide();
          this.newReport_updateGrouping();
        }
      }
    } else if (form_attr === "filters") {
      val = $target.attr('data-value');
      chk = !this.chartNewModel.get("filters")[val];
      filters = this.chartNewModel.get("filters");
      filters[val] = chk;
      this.chartNewModel.set({
        filters: filters
      });
    } else if (form_attr === "settings") {
      val = $target.attr('data-value');
      chk = !this.chartNewModel.get("settings")[val];
      settings = this.chartNewModel.get("settings");
      settings[val] = chk;
      this.chartNewModel.set({
        settings: settings

        /*
        			if newAttr.settings['locationreport']
        				@$("#locationLevel_c").prop("disabled", false)
        			else
        				@$("#locationLevel_c").prop("disabled", true)
         */
      });
    } else {
      return true;
    }
    $inp = $target.find('input');
    setTimeout((function() {
      $inp.prop('checked', chk);
    }), 0);
    return false;
  },
  help: function() {
    return bootbox.dialog({
      title: "Help: Create Reports",
      message: '<center><iframe width="640" height="360" src="https://www.youtube.com/embed/mMdOIuLorE8?rel=0" frameborder="0" allowfullscreen></iframe></center> <div class="panel panel-default"> <div class="panel-heading">Questions <button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" disabled> <i class="fa fa-list-ol"></i> Select Questions <i class="fa fa-caret-down"></i> </button> </div> <div class="panel-body"> <ul> <li>A chart will be generated for each question selected from the dropdown list</li> <li>Sub-Questions will be indented within the main question</li> <li>Selection of a numerical question will create a dropdown to select the value of X-Axis</li> </ul> </div> </div> <div class="panel panel-default"> <div class="panel-heading">X axis</div> <div class="panel-body"> <ul> <li>If a numeric question is selected, this box will appear</li> <li>Select the appropriate value you need as an X-axis parameter in the chart</li> </ul> </div> </div> <div class="panel panel-default"> <div class="panel-heading">Filters <button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" disabled> <i class="fa fa-filter"></i><i class="fa fa-caret-down"></i> </button> </div> <div class="panel-body"> <ul> <li>Checking the filters will apply the slected filters in the left panel to be applied for rendering charts.</li> </ul> </div> </div> </div> <div class="panel panel-default"> <div class="panel-heading">Select Grouping</div> <div class="panel-body"> <ul> <li>Renders one chart each per location based on the selected location level.</li> <li>\'No Grouping\' will generate one chart per question aggregating all the data</li> </ul> </div> </div> <div class="panel panel-default"> <div class="panel-heading">Render <button type="button" class="btn btn-success btn-sm" disabled> Render </button> </div> <div class="panel-body"> <ul> <li>Will generate the charts based on the parameters selected</li> <li>If modifications are required, change the parameters and click \'Render\' again</li> </ul> </div> </div> </div> <div class="panel panel-default"> <div class="panel-heading">Done <button type="button" class="btn btn-warning btn-sm" disabled> Done </button> </div> <div class="panel-body"> <ul> <li>If no more changes are required in the report, click \'Done\'</li> <li>Report can now be saved for loading automatically later. Report can also be downloaded as PDF/WORD/Excel</li> </ul> </div> </div> </div>'
    });
  },
  qtn_template: _.template('<li><a href="#" class="small drpdwn" data-value="{{qtn_id}}" data-attr="questions" tabindex="-1">{{indent}}<input class="chkbox" type="checkbox">&nbsp; {{qtn_text}}</a></li>'),
  newReport_template: _.template('<div class="col-md-12 col-lg-12 col-sm-12"> <!-- QUESTIONS --> <div class="form-group"> <div class="row"> <div class="col-lg-12"> <div class="button-group"> <button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"> <i class="fa fa-list-ol"></i> Select Questions <i class="fa fa-caret-down"></i> </button> <ul id="questionName_c" class="dropdown-menu"> <li><a href="#" class="small" data-value="option1" tabindex="-1"><input type="checkbox">&nbsp;Qtn1</a></li> <li><a href="#" class="small" data-value="option2" tabindex="-1"><input type="checkbox">&nbsp;Qtn2</a></li> <li><a href="#" class="small" data-value="option3" tabindex="-1"><input type="checkbox">&nbsp;Qtn3</a></li> </ul> </div> </div> </div> </div> <!-- Question Ends Here --> <!-- DATA FILTERS --> <div class="form-group"> <div class="row"> <div class="col-lg-12"> <div class="button-group"> <button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"> <i class="fa fa-filter"></i> <i class="fa fa-caret-down"></i> </button> <ul class="dropdown-menu"> <li><a href="#" class="small drpdwn" data-attr="filters" data-value="editorFilterType" tabindex="-1"><input type="checkbox" id="editorFilterType_c">&nbsp;Apply User filter</a></li> <li><a href="#" class="small drpdwn" data-value="dateFilterType" data-attr="filters" tabindex="-1"><input type="checkbox" id="dateFilterType_c">&nbsp;Apply Date Filter</a></li> <li><a href="#" class="small drpdwn" data-value="locFilterType" data-attr="filters" tabindex="-1"><input type="checkbox" id="locFilterType_c">&nbsp;Apply Location Filter</a></li> </ul> </div> </div> </div> </div> <!-- DATA FILTERS END HERE --> <!-- X-AXIS VALUE --> <div class="form-group not_pie legendDiv"> <p class="form-control-static"><b> X axis: </b> </p> <label class="sr-only" for="selectLocation">Numeric data fields use this field as X axis </label> <select id="legendQuestion_c" class="form-control input-sm" style="width: 10em;"> <option value="1">Sub-County</option> <option value="2">Division</option><option value="3">Location</option><option value="4">Sub-location</option><option value="Type_of_water_source">Type of water source-(Page_1)</option><option value="Quality_of_water">Quality of water-(Page_1)</option><option value="Water_availability">Water availability-(Page_1)</option><option value="Ownership">Ownership of waterpoint-(Page_1)</option> </select> </div> <!-- X-AXIS ENDS HERE--> <!-- SETTINGS--> <div class="form-group"> <div class="row"> <div class="col-lg-6"> <div class="button-group"> <button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"> <i class="fa fa-cog"></i> <i class="fa fa-caret-down"></i> </button> <ul class="dropdown-menu"> <li><a href="#" class="small drpdwn" data-value="excludenull" data-attr="settings" tabindex="-1"><input type="checkbox" id="excludenull_c">&nbsp;Exclude Non-Response Values</a></li> <li class="not_pie"><a href="#" class="small drpdwn" data-value="combinenumericfields" data-attr="settings" tabindex="-1"><input type="checkbox" id="combinenumericfields_c">&nbsp;Combine all numeric values into one chart</a></li> <!--<li><a href="#" class="small drpdwn" data-value="locationreport" data-attr="settings" tabindex="-1"><input type="checkbox" id="locationreport_c">&nbsp;Generate separate chart for each location</a></li>--> </ul> </div> </div> </div> </div> <!-- SETTINGS END HERE --> <!-- IF LOCATION SELECTED THEN GROUPING--> <div class="form-group"> <p class="form-control-static"><b>Select Grouping:</b></p> <label class="sr-only" for="selectLocation">Select Grouping</label> <select id="locationLevel_c" class="form-control input-sm" style="width: 10em;"> <!--<option>Sub-County</option> <option>Division</option>--> </select> </div> <!-- GROUPING enD HERES--> <button class="btn btn-sm btn-success" id="render" data-loading-text="<i class=\'fa fa-circle-o-notch fa-spin\'></i> Rendering">Render</button> <i class="editReport help-button fa fa-question-circle" id="help"></i> <button class="btn btn-sm editReport" id="close">Done</button> </div>')
});

root = window || this;

if (root.poimapper == null) {
  root.poimapper = {};
}

if (root.poimapper.views == null) {
  root.poimapper.views = {};
}

root.poimapper.views.ChartNew = ChartNew;

//# sourceMappingURL=../maps/views/ChartNew.js.map
