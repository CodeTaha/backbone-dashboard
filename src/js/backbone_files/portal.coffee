###
This is the main file for running backbone portal
###
root = window or this

chartView = new poimapper.views.ChartView {
	username: "taha"
	user_id: 29
	key: "password"
	showDataAutomatically: false
}
root.chartview = chartView
chartView.render()

loadFakeData = () ->
	chartView.renderReport(AreafakeData)
	chartView.renderReport(AllChartsfakeData)
drawArea = () ->
	margin = 
	top: 20
	right: 55
	bottom: 30
	left: 40
	width = 1000 - (margin.left) - (margin.right)
	height = 500 - (margin.top) - (margin.bottom)
	x = d3.scale.ordinal().rangeRoundBands([
	  0
	  width
	], .1)
	y = d3.scale.linear().rangeRound([
	  height
	  0
	])
	xAxis = d3.svg.axis().scale(x).orient('bottom')
	yAxis = d3.svg.axis().scale(y).orient('left')
	color = d3.scale.ordinal().range([
	  '#001c9c'
	  '#101b4d'
	  '#475003'
	  '#9c8305'
	  '#d3c47c'
	])
	svg = d3.select('body').append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
	d3.csv 'data/crunchbase-quarters.csv', (error, data) ->
	  labelVar = 'quarter'
	  varNames = d3.keys(data[0]).filter((key) ->
	    key != labelVar
	  )

	removePopovers = ->
		$('.popover').each ->
		  $(this).remove()
		  return
		return

	showPopover = (d) ->
		$(this).popover
		  title: d.name
		  placement: 'auto top'
		  container: 'body'
		  trigger: 'manual'
		  html: true
		  content: ->
		    'Quarter: ' + d.label + '<br/>Rounds: ' + d3.format(',')(if d.value then d.value else d.y1 - (d.y0))
		$(this).popover 'show'
		return

  	color.domain varNames
	  data.forEach (d) ->
	    y0 = 0
	    d.mapping = varNames.map((name) ->
	      {
	        name: name
	        label: d[labelVar]
	        y0: y0
	        y1: y0 += +d[name]
	      }
	    )
	    d.total = d.mapping[d.mapping.length - 1].y1
	    return
	x.domain data.map((d) ->
		d.quarter
	)
	y.domain [
	    0
	    d3.max(data, (d) ->
	      d.total
	    )
	]
	svg.append('g').attr('class', 'x axis').attr('transform', 'translate(0,' + height + ')').call xAxis
	svg.append('g').attr('class', 'y axis').call(yAxis).append('text').attr('transform', 'rotate(-90)').attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end').text 'Number of Rounds'
	selection = svg.selectAll('.series').data(data).enter().append('g').attr('class', 'series').attr('transform', (d) ->
		'translate(' + x(d.quarter) + ',0)'
	)
	selection.selectAll('rect').data((d) ->
		d.mapping
	).enter().append('rect').attr('width', x.rangeBand()).attr('y', (d) ->
		y d.y1
	).attr('height', (d) ->
		y(d.y0) - y(d.y1)
	).style('fill', (d) ->
		color d.name
	).style('stroke', 'grey').on('mouseover', (d) ->
		showPopover.call this, d
		return
	).on 'mouseout', (d) ->
		removePopovers()
		return
	legend = svg.selectAll('.legend').data(varNames.slice().reverse()).enter().append('g').attr('class', 'legend').attr('transform', (d, i) ->
		'translate(55,' + i * 20 + ')'
	)
	legend.append('rect').attr('x', width - 10).attr('width', 10).attr('height', 10).style('fill', color).style 'stroke', 'grey'
	legend.append('text').attr('x', width - 12).attr('y', 6).attr('dy', '.35em').style('text-anchor', 'end').text (d) ->
	    return d

AllChartsfakeData = {
	"url": "/json/app/jasper/470073/0/1/0/SUM?key=6BEEDCF70F203CE87927D6E98EAFA7CD&userid=simon&user_id=29&questions=No_male_teachers,No_female_teachers,Population,No_of_boys,No_of_girls&locs=&levels=&users=&fromdate=&todate=&timeinfo=0&userinfo=0&legendid=2&reportType=0&locationLevels=1&combinenumericfields=1&timeseriestype=&locationLevelDataFilter=&orientation=1&rowquestionid=&groupid=2&format=json&excludenull=0&subgroup=",
	"template_params": {
		"poi": "470073",
		"includelocation": "0",
		"newdata": "1",
		"chart": "0",
		"type": "SUM",
		"questions": "No_male_teachers,No_female_teachers,Population,No_of_boys,No_of_girls",
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
		"combinenumericfields": "1",
		"timeseriestype": "",
		"locationLevelDataFilter": "",
		"orientation": "1",
		"rowquestionid": "",
		"groupid": "2",
		"format": "json",
		"excludenull": "0",
		"subgroup": ""
	},
	"data": {
		"chart14":{"title":"403. (a) How many boy child died before attaining 1 month of age ?","no_of_pois":"7964","chart_type":"bar","numeric":true,"chart_variables":{"403. (a) How many boy child died before attaining 1 month of age ?-&Bihar":"12","403. (a) How many boy child died before attaining 1 month of age ?-&UP":"3","No response":"7402","403. (a) How many boy child died before attaining 1 month of age ?-&AP":"126"}},"chart12":{"title":"402. (a) How many boy child died before attaining one year of age ?","no_of_pois":"7964","chart_type":"bar","numeric":true,"chart_variables":{"402. (a) How many boy child died before attaining one year of age ?-&AP":"154","402. (a) How many boy child died before attaining one year of age ?-&Maharashtra":"1","No response":"2106","402. (a) How many boy child died before attaining one year of age ?-&Bihar":"34","402. (a) How many boy child died before attaining one year of age ?-&UP":"37"}},"chart13":{"title":"402. (b) How many Girl child died before attaining one year of age ?","no_of_pois":"7964","chart_type":"bar","numeric":true,"chart_variables":{"402. (b) How many Girl child died before attaining one year of age ?-&Maharashtra":"1","402. (b) How many Girl child died before attaining one year of age ?-&Bihar":"18","402. (b) How many Girl child died before attaining one year of age ?-&UP":"20","402. (b) How many Girl child died before attaining one year of age ?-&AP":"68","No response":"2113"}},"chart11":{"title":"310. How much did you earn a month from the employment/work ?","no_of_pois":"7964","chart_type":"bar","numeric":true,"chart_variables":{"No response":"2054","310. How much did you earn a month from the employment/work ?-&UP":"3700","310. How much did you earn a month from the employment/work ?-&AP":"120040","310. How much did you earn a month from the employment/work ?-&Maharashtra":"118650","310. How much did you earn a month from the employment/work ?-&Bihar":"1502"}},"chart16":{"title":"301b. What is the monthly income of your household from all sources [Impact Assessment(FY-14)] ? ","no_of_pois":"7964","chart_type":"bar","numeric":true,"chart_variables":{"Count-&Bihar":"903","405. How many ANC’s you received when you were last pregnant ?-&Bihar":"592","No response":"1849","301b. What is the monthly income of your household from all sources [Impact Assessment(FY-14)] ? -&AP":"28345989","Count-&UP":"893","301b. What is the monthly income of your household from all sources [Impact Assessment(FY-14)] ? -&Bihar":"4150530","302b. What is your contribution to the monthly income of your household [Impact Assessment(FY-14)] ?-&UP":"601300","301b. What is the monthly income of your household from all sources [Impact Assessment(FY-14)] ? -&UP":"1478005","301a. What is the monthly income of your household from all sources(FY13) ? -&UP":"1171010","302a. What is your contribution to the monthly income of your household(FY13) ?-&AP":"6642700","302b. What is your contribution to the monthly income of your household [Impact Assessment(FY-14)] ?-&AP":"20574295","302a. What is your contribution to the monthly income of your household(FY13) ?-&UP":"321500","301a. What is the monthly income of your household from all sources(FY13) ? -&Maharashtra":"3140503","304. How many earning members are there in your family?-&Maharashtra":"1514","301a. What is the monthly income of your household from all sources(FY13) ? -&AP":"17695850","405. How many ANC’s you received when you were last pregnant ?-&Maharashtra":"3425","302a. What is your contribution to the monthly income of your household(FY13) ?-&Maharashtra":"2523204","405. How many ANC’s you received when you were last pregnant ?-&UP":"262","301a. What is the monthly income of your household from all sources(FY13) ? -&Bihar":"2692818","Count-&Maharashtra":"1249","301b. What is the monthly income of your household from all sources [Impact Assessment(FY-14)] ? -&Maharashtra":"3264629","304. How many earning members are there in your family?-&UP":"1454","304. How many earning members are there in your family?-&AP":"15100","302b. What is your contribution to the monthly income of your household [Impact Assessment(FY-14)] ?-&Maharashtra":"3009199","304. How many earning members are there in your family?-&Bihar":"1394","302b. What is your contribution to the monthly income of your household [Impact Assessment(FY-14)] ?-&Bihar":"2624700","302a. What is your contribution to the monthly income of your household(FY13) ?-&Bihar":"902138","Count-&AP":"4919","405. How many ANC’s you received when you were last pregnant ?-&AP":"20246"}},"chart15":{"title":"403. (b) How many Girl child died before attaining 1 month of age ?","no_of_pois":"7964","chart_type":"bar","numeric":true,"chart_variables":{"403. (b) How many Girl child died before attaining 1 month of age ?-&AP":"51","403. (b) How many Girl child died before attaining 1 month of age ?-&Bihar":"3","No response":"7406","403. (b) How many Girl child died before attaining 1 month of age ?-&UP":"13"}},
		"chart2-Kilifi South": {
			"title": "Water availability2",
			"location": "Kilifi South",
			"no_of_pois": "20",
			"chart_type": "bar",
			"numeric": false,
			"chart_variables": {
				"All year round": "5",
				"Seasonal": "15"
			}
		},
		"chart4-Ganze": {
			"title": "Type of water source",
			"location": "Ganze",
			"no_of_pois": "6",
			"chart_type": "pie",
			"numeric": false,
			"chart_variables": {
				"Rivers": "1",
				"Piped": "3",
				"Roof water catchment": "0",
				"Wells": "1",
				"Water pans": "0",
				"Boreholes": "1"
			}
		}
	}
}

#
AreafakeData={
	"url": "/json/app/jasper/469066/0/1/1/SUM?key=EDF5DD625658B29AA55F881CA5B9D5E6&userid=simon&user_id=29&questions=No_of_villages_it_serves,Type,Ownership,No_of_doctors,No_of_clinical_officers,No_of_nurses&locs=&levels=&users=&fromdate=&todate=&timeinfo=0&userinfo=0&legendid=modified&reportType=0&locationLevels=0&combinenumericfields=0&timeseriestype=WEEK&locationLevelDataFilter=&orientation=1&rowquestionid=&groupid=2&format=json&excludenull=0&subgroup=",
	"template_params": {
		"key": "EDF5DD625658B29AA55F881CA5B9D5E6",
		"userid": "simon",
		"user_id": "29",
		"questions": "No_of_villages_it_serves,Type,Ownership,No_of_doctors,No_of_clinical_officers,No_of_nurses",
		"locs": "",
		"levels": "",
		"users": "",
		"fromdate": "",
		"todate": "",
		"timeinfo": "0",
		"userinfo": "0",
		"legendid": "modified",
		"reportType": "0",
		"locationLevels": "0",
		"combinenumericfields": "0",
		"timeseriestype": "WEEK",
		"locationLevelDataFilter": "",
		"orientation": "1",
		"rowquestionid": "",
		"groupid": "2",
		"format": "json",
		"excludenull": "0",
		"subgroup": "",
		"poi": "469066",
		"includelocation": "0",
		"newdata": "1",
		"chart": "1",
		"type": "SUM"
	},
	"data": {
		"chart1": {
			"title": "Number of villages it serves",
			"no_of_pois": "19",
			"chart_type": "area",
			"numeric": false,
			"chart_variables": {
				"Number of villages it serves": "[{ \"x\":1.0,\"y\":12},{ \"x\":10.0,\"y\":34},{ \"x\":17.0,\"y\":74},{ \"x\":18.0,\"y\":5},{ \"x\":20.0,\"y\":63},{ \"x\":33.0,\"y\":34},{ \"x\":34.0,\"y\":17},{ \"x\":38.0,\"y\":10000},{ \"x\":45.0,\"y\":1},{ \"x\":48.0,\"y\":18}]",
				"No response": "0"
			}
		},
		"chart2": {
			"title": "Type",
			"no_of_pois": "19",
			"chart_type": "area",
			"numeric": false,
			"chart_variables": {
				"Type-&Private Clinic": "[{ \"x\":10.0,\"y\":1},{ \"x\":17.0,\"y\":1},{ \"x\":33.0,\"y\":1}]",
				"No response": "0",
				"Type-&District": "[{ \"x\":17.0,\"y\":1},{ \"x\":33.0,\"y\":1},{ \"x\":45.0,\"y\":1}]",
				"Type-&Dispensary": "[{ \"x\":10.0,\"y\":2},{ \"x\":34.0,\"y\":2}]",
				"Type-&Health centre": "[{ \"x\":1.0,\"y\":1},{ \"x\":10.0,\"y\":1},{ \"x\":18.0,\"y\":1},{ \"x\":20.0,\"y\":3},{ \"x\":33.0,\"y\":1},{ \"x\":38.0,\"y\":1},{ \"x\":48.0,\"y\":1}]"
			}
		},
		"chart3": {
			"title": "Ownership",
			"no_of_pois": "19",
			"chart_type": "area",
			"numeric": false,
			"chart_variables": {
				"Ownership-&Religious sponsored": "[{ \"x\":17.0,\"y\":1}]",
				"Ownership-&Private": "[{ \"x\":10.0,\"y\":2},{ \"x\":17.0,\"y\":1},{ \"x\":18.0,\"y\":1},{ \"x\":20.0,\"y\":2},{ \"x\":33.0,\"y\":1},{ \"x\":45.0,\"y\":1},{ \"x\":48.0,\"y\":1}]",
				"No response": "0",
				"Ownership-&Government": "[{ \"x\":1.0,\"y\":1},{ \"x\":10.0,\"y\":2},{ \"x\":20.0,\"y\":1},{ \"x\":33.0,\"y\":2},{ \"x\":34.0,\"y\":2},{ \"x\":38.0,\"y\":1}]"
			}
		},
		"chart4": {
			"title": "Number of Doctors",
			"no_of_pois": "19",
			"chart_type": "line",
			"numeric": false,
			"chart_variables": {
				"No response": "0",
				"Number of Doctors": "[{ \"x\":1.0,\"y\":21},{ \"x\":10.0,\"y\":7},{ \"x\":17.0,\"y\":59},{ \"x\":18.0,\"y\":2},{ \"x\":20.0,\"y\":58},{ \"x\":33.0,\"y\":3},{ \"x\":34.0,\"y\":6},{ \"x\":38.0,\"y\":20},{ \"x\":45.0,\"y\":1},{ \"x\":48.0,\"y\":1}]"
			}
		},
		"chart5": {
			"title": "Number of clinical officers",
			"no_of_pois": "19",
			"chart_type": "area",
			"numeric": false,
			"chart_variables": {
				"No response": "0",
				"Number of clinical officers": "[{ \"x\":1.0,\"y\":36},{ \"x\":10.0,\"y\":12},{ \"x\":17.0,\"y\":15},{ \"x\":18.0,\"y\":5},{ \"x\":20.0,\"y\":47},{ \"x\":33.0,\"y\":46},{ \"x\":34.0,\"y\":7},{ \"x\":38.0,\"y\":50},{ \"x\":45.0,\"y\":2},{ \"x\":48.0,\"y\":0}]"
			}
		},
		"chart6": {
			"title": "Number of nurses",
			"no_of_pois": "19",
			"chart_type": "area",
			"numeric": false,
			"chart_variables": {
				"Number of nurses": "[{ \"x\":1.0,\"y\":51},{ \"x\":10.0,\"y\":16},{ \"x\":17.0,\"y\":18},{ \"x\":18.0,\"y\":5},{ \"x\":20.0,\"y\":49},{ \"x\":33.0,\"y\":63},{ \"x\":34.0,\"y\":11},{ \"x\":38.0,\"y\":20},{ \"x\":45.0,\"y\":3},{ \"x\":48.0,\"y\":1}]",
				"No response": "0"
			}
		}
	},
}
loadFakeData()