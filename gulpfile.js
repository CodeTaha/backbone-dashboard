var gulp = require('gulp'),
	args = require('yargs').argv,
	$ = require('gulp-load-plugins')({lazy:true}),
	del = require('del'),
	browserSync = require('browser-sync');

var config = require('./gulp.config')();
var port = process.env.PORT || config.defaultPort;


gulp.task('default', function() {
  // place code for your default task here
});

gulp.task('help', $.taskListing);


gulp.task('backbone', function() {
	log('Compiling Backbone\'s COFFEE --> JS');
	// Attach listener
	return gulp.src(config.backbone)
		//.pipe($.newer(config.backbone_dest))
		.pipe($.if(args.verbose, $.print()))
		.pipe($.sourcemaps.init())
		.pipe($.plumber()) // error logging
		.pipe($.coffee({ bare: true }))
		//.on('error', errorLogger)
		.pipe($.sourcemaps.write('./maps'))
		.pipe(gulp.dest(config.backbone_dest));
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

gulp.task('inject',['wiredep', 'styles'], function(){     
	log("Running Inject to inject resources and CSS");     
	
	return gulp
		.src(config.index)
		.pipe($.inject(gulp.src(config.styl_dest + '/**.css')))
		.pipe(gulp.dest('./')); //TODO config ? 
});

gulp.task('clean-styles', function(done){
	var files = config.styl_dest +'**/*.css'
	clean(files, done);
});

gulp.task('watch', function(done){
	gulp.watch([config.styl], ['styles']);
	gulp.watch([config.backbone], ['backbone']);
	startBroswerSync();
});

gulp.task('serve-dev', ['inject'], function(){
	var isDev = true;
	var nodeOptions = {
		script: config.nodeServer,
		delayTime: 1,
		env: {
			'PORT': port,
			'NODE_ENV': isDev ? 'dev' : 'build'
		},
		watch : [config.server]
	};
	return $.nodemon(nodeOptions)
	.on('restart', function(ev) {
		log('*** Nodemon restarted ***')
		log('files changed on restart :\n' + ev);
	})
	.on('start', function() {
		log('** Nodemon started ***');
		
	})
	.on('crash', function() {
		log('!!! Nodemon Crashed: Script crashed for some reason')
	})
	.on('exit', function() {
		log('** nodemon exited ***')
	});	

})
//////
function startBroswerSync(){
	if(args.nosync || browserSync.active) {
		return;
	}
	log('starting browser-sync on port ' +port);
	var options = {
		proxy: 'localhost:' + port,
		port: 3001,
		files: ['./res/**/*.*'],
		ghostMode: {
			clicks: true,
			location: false,
			forms: true,
			scroll: true,
		},
		injectChanges: true,
		logFileCHanges: true,
		loglevel: 'debug',
		logPrefix: 'gulp-patterns',
		notify: true,
		reloadDelay: 1000

	};
	browserSync(options);
}
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