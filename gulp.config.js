module.exports = function(){
	var src = './src/';
	var server = './src/server/'
	var config = {
		temp: './res/.tmp',
		
		/*
		* For .coffee files
		*/
		backbone:[
			src + 'js/backbone_files/**/*.coffee',
			src + 'js/backbone_files/*.coffee'
			],
		backbone_dest: './res/js/backbone',

		/* For .styl files*/
		styl: [
			src + 'css/*.styl'
		],
		styl_dest: './res/css',
		index: './index.html',
		js: [
			'./res/js/**.js',
			'./res/js/backbone/models/**.js',
			'./res/js/backbone/collections/**.js',
			'./res/js/backbone/views/**.js',
			'./res/js/backbone/**.js',
		],

		/*
		* Bower and NPM locations
		*/
		bower:{
			json: require('./bower.json'),
			directory: './res/vendor/',
			ignorePath: '../../'
		},
		/*
		* Node Settings
		*/
		server: server,
		defaultPort:3000,
		nodeServer: './server.js'

	};
	config.getWiredepDefaultOptions = function() {
		var options = {
			bowerJson: config.bower.json,
			directory: config.bower.directory,
			ignorePath: config.bower.ignorePath
		}
	}
	return config;
};