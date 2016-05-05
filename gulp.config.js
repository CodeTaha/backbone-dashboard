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
		styl_dest: './res/css'

	};
	return config;
};