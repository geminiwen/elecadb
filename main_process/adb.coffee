Promise = require 'bluebird'
fs = require 'fs'
adb = require 'adbkit'
client = adb.createClient()
temp = require('temp').track()
debug = require('debug') 'adb'
nativeImage = require('electron').nativeImage
Progress = require 'progress-stream'
rp = require 'request-promise'
request = require 'request-promise'
unzip = require 'unzip'
Promise = require 'bluebird'
path = require 'path'
storage = require('electron-json-storage')

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
            debug err
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
            debug err
            event.sender.send 'downloadApk', err

    _realDownloadApk: (dirPath, progress) =>
        project = null
        getData = Promise.promisify(storage.get)
        resultApkPath = path.join dirPath, "_tmp.apk"
        getData("project")
        .then (data) =>
            project = data
            if not project then return Promise.reject Error("settings")
            url = "http://api.fir.im/apps/#{data.projectId}/download_token?api_token=#{data.personalToken}"
            rp url
        .then (data) ->
            console.log data
            data = JSON.parse data
            data['download_token']
        .then (token) ->
            return new Promise (resolve, reject) ->
                request "http://download.fir.im/apps/#{project.projectId}/install?download_token=#{token}"
                .on 'response', (res) ->
                    if res.statusCode >= 400
                        reject Error('download failed')
                    progress.setLength(parseInt(res.headers['content-length'] || 0))
                .on 'error', (err) ->
                    reject err
                .pipe progress
                .pipe fs.createWriteStream(resultApkPath)
                .on 'finish', ->
                    resolve resultApkPath



    installApk: (event, deviceId, path) =>
        client.install(deviceId, path)
        .then ->
            event.sender.send 'installApk'
        .catch (e) ->
            event.sender.send 'installApk', e
    launch: (event, id, component, activity, params) ->
        options = {
            'component': "#{component}/#{activity}",
            'extras': params
        }
        client.startActivity id, options
        .then ->
            event.sender.send 'launch'
        .catch (e) ->
            debug e
            event.sender.send 'launch', e

module.exports = exports = ADB;