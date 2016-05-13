module.exports = function(){
	var src = './src/';
	var config = {
		temp: './res/.tmp',
		
		/*
		* For .coffee files
		*/
		coffee:[
			src + 'js/coffee_files/**/*.coffee',
			src + 'js/coffee_files/*.coffee'
			],
		coffee_dest: './res/js',

		/* For .styl files*/
		styl: [
			src + 'css/*.styl'
		],
		styl_dest: './res/css',
		index: './index.html',
		js: [
			'./res/js/**.js',
			'./res/js/**/**.js'
		],

		/*
		* Bower and NPM locations
		*/
		bower:{
			json: require('./bower.json'),
			directory: './res/vendor/',
			ignorePath: '../../'
		}

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