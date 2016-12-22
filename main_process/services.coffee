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
        ipcMain.on 'request-devices', @adb.listDevices
        ipcMain.on 'request-screencap', @adb.screenCap
        ipcMain.on 'request-saveImage', this.saveImage
        ipcMain.on 'request-installApk', @adb.installApk

    saveImage: (event, dataUrl) ->
        options = {
            title: 'Save an Image',
            filters: [{ name: 'Images', extensions: ['png'] }]
        }
        dialog.showSaveDialog options, (fileName) ->
            if !fileName then return
            image = nativeImage.createFromDataURL dataUrl
            fs.createWriteStream(fileName).write image.toPNG(), (err) ->
                event.sender.send('saveImage', err);

       


module.exports = Services