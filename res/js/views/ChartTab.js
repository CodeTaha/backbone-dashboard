var ChartTab, root;

ChartTab = Backbone.View.extend({
  tagName: "li",
  events: {
    "click a": "templateChange"
  },
  initialize: function(options) {
    var temp;
    _.bindAll(this, 'render', 'appendList', 'change', 'createPanel', 'unrender', 'changeReport_Title', 'templateChange', 'focus', 'selectionChange');
    this.parent = options.parent;
    this.chartSelectionModel = options.chartSelectionModel;
    this.showDataAutomatically = this.parent.showDataAutomatically;
    if (this.model.get("template")) {
      temp = this.model.get("template_data");
      temp.template_params = this.getQueryParams(temp.url);
      this.model.set({
        template_data: temp
      });
    }
    this.listenTo(this.chartSelectionModel, 'change:formIds', this.selectionChange);
    this.model.bind('remove', this.unrender);
    return this.model.on("change:report_title", this.changeReport_Title);
  },
  render: function() {
    this.model.set({
      checked: true
    });
    if (this.model.get("newChart")) {
      this.model.set({
        loaded: false
      });
      this.parent.$el.prepend(this.createPanel().render().$el);
    } else if (this.model.get("template")) {
      this.model.set({
        loaded: true
      });
      this.parent.$el.append(this.createPanel().render().$el);
    } else {
      this.model.set({
        loaded: true
      });
      this.parent.$el.append(this.createPanel().render().$el);
      this.chartPanel.createChartModels();
    }
    return this;
  },
  createPanel: function() {
    this.chartPanel = new poimapper.views.ChartPanel({
      model: this.model,
      parent: this,
      superParent: this.parent,
      chartSelectionModel: this.chartSelectionModel
    });
    return this.chartPanel;
  },
  appendList: function() {
    var chk, tempclass;
    tempclass = '';
    if (this.model.get("template")) {
      tempclass = 'template';
    } else {
      tempclass = 'notemplate';
    }
    chk = 'checked';
    if (!this.model.get("checked")) {
      chk = '';
    }
    this.$el.append(this.li_template({
      "report_title": this.model.get("report_title"),
      "report_id": this.model.get("report_id"),
      "checked": chk,
      "tempclass": tempclass
    }));
    this.$("i").hide();
    return this;
  },
  selectionChange: function() {
    var formIds, poi;
    poi = this.model.get("template_data").template_params.poi;
    formIds = this.chartSelectionModel.get("formIds");
    if (this.chartSelectionModel.get("formIds").length === 0) {
      this.$el.removeClass("filtered");
    } else if (this.model.get("template") && !this.model.get("loaded") && formIds.indexOf(poi) === -1) {
      this.$el.addClass("filtered");
    } else {
      this.$el.removeClass("filtered");
    }
    if (false && this.showDataAutomatically && this.model.get("template") && !this.model.get("loaded") && formIds.indexOf(poi) !== -1) {
      this.templateChange();
    }
  },
  focus: function() {
    if (this.model.get("loaded")) {
      location.hash = "#" + this.model.get("report_id");
      return true;
    } else {
      return this.templateChange();
    }
  },
  change: function() {
    var chk, self;
    this.model.set({
      checked: !this.model.get("checked")
    });
    chk = this.model.get("checked");
    self = this;
    setTimeout((function() {
      self.$('.chkbox').prop('checked', chk);
      self.chartPanel.show_hide();
    }), 0);
    return false;
  },
  templateChange: function() {
    var chk, self;
    if (this.model.get("loaded")) {
      return this.change();
    } else {
      this.$("i").show();
      chk = true;
      self = this;
      setTimeout((function() {
        self.$el.toggleClass('active');
        self.$('.chkbox').prop('checked', chk);
        self.render();
        self.chartPanel.fetchReport(function() {
          self.$("i").hide();
          self.$el.toggleClass('active');
          return self.chartPanel.createChartModels();
        });
      }), 0);

      /*
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
       */
      return false;
    }
  },
  unrender: function() {
    return this.$el.remove();
  },
  changeReport_Title: function() {
    return this.$("label").html(this.model.get("report_title"));
  },
  li_template: _.template('<a href="\#{{ report_id }}" class="{{tempclass}}"> <input class="chkbox" type="checkbox" {{checked}} aria-label="..."> <i class=\'fa fa-circle-o-notch fa-spin\'></i> <label>{{ report_title }}</label> </a>'),
  getQueryParams: function(qs) {
    var params, path_params, preqs, re, tokens;
    params = void 0;
    re = void 0;
    tokens = void 0;
    qs = qs.split('+').join(' ');
    preqs = [];
    preqs[0] = qs.substring(0, qs.indexOf('?'));
    preqs[1] = qs.substring(qs.indexOf('?') + 1);
    path_params = preqs[0].split('/').slice(4);
    qs = preqs[1];
    params = {};
    tokens = void 0;
    re = /[?&]?([^=]+)=([^&]*)/g;
    while (tokens = re.exec(qs)) {
      params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
    }
    params.poi = path_params[0];
    params.includelocation = path_params[1];
    params.newdata = path_params[2];
    params.chart = path_params[3];
    params.type = path_params[4];
    params.locs = '';
    params.users = '';
    params.fromdate = '';
    params.todate = '';
    return params;
  }
});

root = window || this;

if (root.poimapper == null) {
  root.poimapper = {};
}

if (root.poimapper.views == null) {
  root.poimapper.views = {};
}

root.poimapper.views.ChartTab = ChartTab;

//# sourceMappingURL=../maps/views/ChartTab.js.map
