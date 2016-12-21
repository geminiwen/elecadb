gulp = require 'gulp'

electron = require('electron-connect').server.create()

gulp.task 'serve', =>

    # Start browser process
    electron.start()

    # Restart browser process
    gulp.watch ['adb.coffee', 'index.js'], electron.restart

    # Reload renderer process
    gulp.watch ['render/scripts/*.coffee',
                'render/stylesheet/*.css',
                'index.html'], electron.reload

gulp.task 'default', ['serve']