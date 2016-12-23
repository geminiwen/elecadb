Promise = require 'bluebird'
fs = require 'fs'
adb = require 'adbkit'
client = adb.createClient()
temp = require 'temp'
debug = require('debug') 'adb'
nativeImage = require('electron').nativeImage
Progress = require 'progress-stream'
request = require 'request'
unzip = require 'unzip'
path = require 'path'

parseDevices = (devices) ->
    Promise.map devices, (device) ->
        client.shell device.id, "getprop ro.product.model"
        .then adb.util.readAll
        .then (output) ->
            deviceName = output.toString().trim()
            device.name = deviceName
            return device
        .then (device) ->
            client.shell(device.id, "getprop ro.product.manufacturer")
        .then adb.util.readAll
        .then (output) ->
            brand = output.toString().trim()
            device.brand = brand
            return device



class ADB
    constructor: (@win) ->
        this.track()
    track: () =>
        client.trackDevices()
            .then (tracker) =>
                updateDevice = =>
                    client.listDevices()
                    .then (devices) =>
                        parseDevices devices
                    .then (devices) =>
                        @win.webContents.send("devices", devices)

                tracker.on 'change', updateDevice
                tracker.on 'remove', updateDevice
            .catch (ex) =>
                debug ex

    listDevices: (event) =>
        client.listDevices()
        .then (devices) =>
            parseDevices devices
        .then (devices) =>
            event.sender.send "devices", devices
        .catch (ex) =>
            debug ex

    screenCap: (event, deviceId) =>
        client.screencap deviceId
        .then adb.util.readAll
        .then (output) =>
            image = nativeImage.createFromBuffer output
            event.sender.send "screencap", undefined , image.toDataURL()
        .catch (ex) =>
            event.sender.send "screencap", ex

    downloadApk: (event) =>
        progress = Progress {time: 100}
        .on 'progress', (state) ->
            # progress
            event.sender.send 'downloadApk', undefined, 'progress', state.percentage
        .on 'error', (err) ->
            console.error err
            event.sender.send 'downloadApk', err
        .on 'end', ->
            # end
        mkdir = Promise.promisify(temp.mkdir)

        mkdir 'temp'
        .then (tempPath) =>
            this._realDownloadApk tempPath, progress
        .then (apkPath) ->
            # start install
            event.sender.send 'downloadApk', undefined, 'complete', apkPath
        .catch (err) ->
            # error
            console.error err
            event.sender.send 'downloadApk', err

    _realDownloadApk: (dirPath, progress) =>
        privateToken = 'VFuvYLhMUZgpp-sK_Ej6'
        projectId = 15

        return new Promise (resolve, reject) ->
            request.get
                url: "http://10.0.10.211:9001/api/v3/projects/#{projectId}/builds/artifacts/develop/download?job=publish",
                headers:
                    'PRIVATE-TOKEN': privateToken
            .on 'response', (res) ->
                #TODO: deal with statusCode
                progress.setLength parseInt(res.headers['content-length'])
            .on 'error', (err) ->
                reject err
            .pipe progress
            .pipe unzip.Extract
                path: dirPath
            .on 'finish', ->
                resolve path.join(dirPath, 'app/build/outputs/apk/app-official-rc.apk')


    installApk: (event, deviceId, path) =>
        client.install(deviceId, path)
        .then ->
            event.sender.send 'installApk'
        .catch (e) ->
            event.sender.send 'installApk', e
    launch: (event, id) ->
        options = {
            'component': 'com.segmentfault.app/com.segmentfault.app.activity.MainActivity',
            'extras': [{
                key: 'API_LEVEL'
                type: 'int'
                value: '1'
            }]
        }
        client.startActivity id, options
        .then ->
            event.sender.send 'launch'
        .catch (e) ->
            debug e
            event.sender.send 'launch', e

module.exports = exports = ADB;