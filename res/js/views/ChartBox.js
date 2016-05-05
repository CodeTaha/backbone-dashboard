var ChartBox, root;

ChartBox = Backbone.View.extend({
  tagName: 'div',
  className: 'col-sm-6 col-md-6 col-lg-4',
  events: {
    "click button.maxButton": "maxMinChart",
    "click button.download": "downloadChart"
  },
  initialize: function(options) {
    _.bindAll(this, 'render', 'unrender', 'maxMinChart', 'createChart', 'downloadChart');
    this.chart = new Chart;
    this.parent = options.parent;
    this.model.bind('remove', this.unrender);
    return this.maxMinFlag = false;
  },
  render: function() {
    var location;
    switch (this.model.get("chart_type")) {
      case 'bar':
        this.chart_type = 'bar';
        break;
      case 'pie':
        this.chart_type = 'pie';
    }
    location = this.model.get("location") !== null ? "<span class='glyphicon glyphicon-map-marker' aria-hidden='true'></span>" + this.model.get("location") : "<h5>&nbsp;</h5>";
    if (this.model.get("loc_title") == null) {
      $(this.el).html(this.viz_template({
        "graph_title": this.model.get("title"),
        "counter": this.model.cid,
        "chart_type": this.chart_type + "_c",
        "data_id": this.model.cid,
        "pois": this.model.get("no_of_pois")
      }));
    } else {
      $(this.el).html(this.viz_template({
        "graph_title": location,
        "counter": this.model.cid,
        "chart_type": this.chart_type + "_c",
        "data_id": this.model.cid,
        "pois": this.model.get("no_of_pois")
      }));
    }
    return this;
  },
  unrender: function() {
    return this.$el.remove();
  },
  downloadChart: function() {
    var canvas, img, link;
    this.$el.append('<canvas id="drawingArea"></canvas>');
    console.log("Download", this.model);
    canvg(document.getElementById('drawingArea'), '<svg class="' + this.chart_type + "_c" + '" width="' + $("#viz_" + this.model.cid + " svg").width() + '" height="' + $("#viz_" + this.model.cid + " svg").height() + '">' + $("#viz_" + this.model.cid + " svg").html() + '</svg>');
    canvas = document.getElementById('drawingArea');
    img = canvas.toDataURL("image/png");
    link = document.createElement("a");
    link.download = this.model.get("title").replace(/[^A-Z0-9]+/ig, "_") + ".png";
    if (this.model.get("location") != null) {
      link.download = this.model.get("title").replace(/[^A-Z0-9]+/ig, "_") + "-" + this.model.get("location").replace(/[^A-Z0-9]+/ig, "_") + ".png";
    }
    link.href = img;
    link.click();
    return this.$("#drawingArea").remove();
  },
  createChart: function() {
    switch (this.chart_type) {
      case 'bar':
        return this.bar(function(err, success) {});
      case 'pie':
        return this.pie(function(err, success) {});
    }
  },
  maxMinChart: function() {
    this.maxMinFlag = !this.maxMinFlag;
    if (this.maxMinFlag) {
      this.$el.removeClass().addClass("col-sm-12 col-md-12 col-lg-12 maximizeChart");
      this.$("." + this.chart_type + "_c").empty();
      this.$(".maxButton").html('<i class="fa fa-search-minus"></i>');
    } else {
      this.$el.removeClass().addClass("col-sm-6 col-md-6 col-lg-4");
      this.$("." + this.chart_type + "_c").empty();
      this.$(".maxButton").html('<i class="fa fa-search-plus"></i>');
    }
    return this.createChart();
  },
  bar: function(cb) {
    var data;
    data = this.model.get("chart_variables");
    if (this.model.get("numeric") === true && this.parent.model.get("template_data").template_params.combinenumericfields === "1") {
      this.chart.barCombine("#viz_" + this.model.cid, data, this.maxMinFlag);
    } else {
      this.chart.bar("#viz_" + this.model.cid, data, "key", "value", this.model.get("numeric"), this.maxMinFlag);
    }
    return cb(null, true);
  },
  pie: function(cb) {
    var data;
    data = this.model.get("chart_variables");
    this.chart.pie("#viz_" + this.model.cid, data, "key", "value", this.maxMinFlag);
    return cb(null, true);
  },
  area: function(cntr, cb) {
    var chart_local, data, parseDate;
    data = void 0;
    parseDate = void 0;
    parseDate = d3.time.format('%d-%b-%y').parse;
    chart_local = this.chart;
    this.$el.append(this.viz_template({
      'graph_title': 'Area_' + cntr,
      'counter': cntr,
      'chart_type': 'area_c',
      "data_id": "null"
    }));
    data = d3.json('res/js/areaData.js', function(error, data2) {
      if (error) {
        throw error;
      }
      data2.forEach(function(d) {
        d.date = parseDate(d.date);
        d.close = +d.close;
      });
      chart_local.area('#viz_' + cntr, data2, 'date', 'close');
      return data2;
    });
    return cb(null, true);
  },
  line: function(cntr, cb) {
    var chart_local, data, parseDate;
    parseDate = d3.time.format('%d-%b-%y').parse;
    this.$el.append(this.viz_template({
      'graph_title': 'Line' + cntr,
      'counter': cntr,
      'chart_type': 'line_c',
      'data_id': 'null'
    }));
    chart_local = this.chart;
    data = d3.json('res/js/areaData.js', function(error, data2) {
      if (error) {
        throw error;
      }
      data2.forEach(function(d) {
        d.date = parseDate(d.date);
        d.close = +d.close;
      });
      chart_local.line('#viz_' + cntr, data2, 'date', 'close');
      return data2;
    });
    return cb(null, true);
  },
  viz_template: _.template('<div class="well chartBox"> <div class="chartTitle row-fluid"> <div class="col-md-8 graphTitle" title="{{ graph_title }}"> <div class="row"> <h5>{{ graph_title }}</h5> <h6>POI\'s: {{ pois }}</h6> </div> </div> <button type=\"button\" class=\"btn btn-xs btn-default download\" style="float:right;"> <i class=\"fa fa-download\"></i> </button> <!--<button type="button" class="btn btn-xs btn-default maxButton" aria-label="Maximize" style="float:right;" data-target="#maxModal" data-toggle="modal" data-id="{{data_id}}">--> <button type="button" class="btn btn-xs btn-default maxButton" aria-label="Maximize" style="float:right;"> <i class="fa fa-search-plus"></i> </button> </div> <div class="{{chart_type}}" id=\"viz_{{ counter }}\"> </div> </div>')
});

root = window || this;

if (root.poimapper == null) {
  root.poimapper = {};
}

if (root.poimapper.views == null) {
  root.poimapper.views = {};
}

root.poimapper.views.ChartBox = ChartBox;

//# sourceMappingURL=../maps/views/ChartBox.js.map
