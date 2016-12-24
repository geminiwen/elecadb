gulp = require 'gulp'
webpack = require 'webpack'
webpackConfig = require './webpack.config.js'
debug = require('debug') 'gulp'
gutil = require 'gulp-util'
useref = require 'gulp-useref'

electron = require('electron-connect').server.create()

devCompiler = webpack webpackConfig

gulp.task 'webpack:build', (callback) ->
    devCompiler.run (err, status) ->
        #TODO deal with err and status
        throw new gutil.PluginError('webpack:build', err) if err?
        gutil.log '[webpack:build]', status.toString({colors: true});
        callback()

gulp.task 'watch', ['webpack:build'], =>

    # Start browser process
    electron.start()

    # Restart browser process
    gulp.watch ['main_process/*.coffee', 'index.js'], electron.restart
    gulp.watch ['render/src/**/*.{css,js,vue}', 
                'render/*.html']
    , ['webpack:build'], electron.reload


gulp.task 'default', ['watch']