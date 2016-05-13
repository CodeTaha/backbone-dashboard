var gulp = require('gulp'),
	args = require('yargs').argv,
	$ = require('gulp-load-plugins')({lazy:true}),
	del = require('del');

var config = require('./gulp.config')();



gulp.task('default', function() {
  // place code for your default task here
});

gulp.task('coffee', function() {
	log('Compiling COFFEE --> JS');
	// Attach listener
	return gulp.src(config.coffee)
		.pipe($.if(args.verbose, $.print()))
		.pipe($.sourcemaps.init())
		.pipe($.plumber()) // error logging
		.pipe($.coffee({ bare: true }))
		//.on('error', errorLogger)
		.pipe($.sourcemaps.write('./maps'))
		.pipe(gulp.dest(config.coffee_dest));
});

gulp.task('styles', ['clean-styles'], function(){
	log('Compiling Stylus --> CSS');
	return gulp
		.src(config.styl) //TODO
		.pipe($.plumber()) // for error logging
		.pipe($.stylus()) // Compiles stylus
		//.on('error', errorLogger) // Used for our own error logging
		.pipe($.autoprefixer({browsers: ['last 2 version', '>5%']})) // Add support for different browser platforms
		.pipe(gulp.dest(config.styl_dest)) 

});

gulp.task('wiredep', function(){     
	log("Running Wiredep to inject resources");     
	var options = config.getWiredepDefaultOptions(); //TODO
	var wiredep = require('wiredep').stream;
	return gulp
		.src(config.index)
		.pipe($.wiredep(options))
		.pipe($.inject(gulp.src(config.js)))
		.pipe(gulp.dest('./')); //TODO config ? 
	});

gulp.task('clean-styles', function(done){
	var files = config.styl_dest +'**/*.css'
	clean(files, done);
});

gulp.task('watch', function(done){
	gulp.watch([config.styl], ['styles']);
	gulp.watch([config.coffee], ['coffee']);
});

//////

function errorLogger(error){
	log('*** Start of ERROR ***');
	log(error);
	log('*** End of ERROR ***');
	this.emit('end');
}

function clean(path, done){
	log('Cleaning: '+ $.util.colors.blue(path));
	del(path)
	done();
}
function log(msg){
	if(typeof(msg) === 'object'){
		for(var item in msg) {
			if(msg.hasOwnProperty(item)){
				$.util.log($.util.colors.blue(msg[item]));
			}
		}
	} else {
		$.util.log($.util.colors.blue(msg));
	}
}