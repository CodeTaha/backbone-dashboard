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
fakeData = {
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
			"title": "Water availability",
			"location": "Kilifi South",
			"no_of_pois": "20",
			"chart_type": "pie",
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

chartView.renderReport(fakeData)