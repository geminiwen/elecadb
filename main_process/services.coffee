ADB = require '../adb'
fs = require "fs"
Progress = require 'progress-stream'

request = require 'request'
{nativeImage, dialog, ipcMain} = require 'electron'

# ***
# IPC Services here
# ***

class Services
    constructor: (@win) ->
        @adb = new ADB @win
        this.prepare()

    prepare: () =>
        ipcMain.on('request-devices', @adb.listDevices);
        ipcMain.on('request-screencap', @adb.screenCap);
        ipcMain.on('request-saveImage', this.saveImage);
        ipcMain.on('request-downloadApk', this.downloadApk);

    saveImage: (event, dataUrl) ->
        options = {
            title: 'Save an Image',
            filters: [{ name: 'Images', extensions: ['png'] }]
        }
        dialog.showSaveDialog options, (fileName) ->
            image = nativeImage.createFromDataURL dataUrl
            fs.createWriteStream(fileName).write image.toPNG(), (err) ->
                event.sender.send('saveImage', err);

    downloadApk: (event, progress) ->
        privateToken = 'VFuvYLhMUZgpp-sK_Ej6'

        progress = Progress {time: 100}
        .on 'progress', (state) ->
            console.log state
        .on 'error', (err) ->
            console.log err
        .on 'end', ->
            console.log 'complete'

        request.get
            url: 'http://10.0.10.211:9001/api/v3/projects/15/builds/artifacts/develop/download?job=publish',
            headers:
                'PRIVATE-TOKEN': privateToken
        .on 'error', (err) ->
            console.error err
        .on 'response', (response) ->
            console.log response.statusCode
            # deal with status code
            progress.setLength parseInt(response.headers['content-length'])
        .pipe progress
        .pipe fs.createWriteStream("/tmp/a.zip")

module.exports = Services