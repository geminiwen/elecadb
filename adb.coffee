Promise = require 'bluebird'
fs = require 'fs'
adb = require 'adbkit'
client = adb.createClient()
temp = require 'temp'
debug = require('debug') 'adb'
nativeImage = require('electron').nativeImage

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
            event.sender.send "screencap", image.toDataURL()
        .catch (ex) =>
            debug ex

module.exports = exports = ADB;