$ = require 'jquery'
window.jQuery = $
require('./../../assets/javascript/bootstrap.min')

mintUI = require './../../assets/javascript/mint-ui'
Vue = require './../../assets/javascript/vue'
Indicator = mintUI.Indicator
{remote} = require 'electron'
fs = require 'fs'
Promise = require 'bluebird'
progress = require 'request-progress'
{Menu, MenuItem, dialog, nativeImage} = remote
temp = require 'temp'

ipc = require('electron').ipcRenderer
debug = require('debug') 'render'
request = require 'request'

document.addEventListener "DOMContentLoaded", =>
    Vue.use mintUI

    data =
        devices: [],
        screencap: undefined,
        downloadingApk: false
        downloadProgress: 0

    capture = =>
        id = $('.device.selected').data 'device'
        if id is no
            $('.alert').show()
        else
            ipc.send 'request-screencap', id
            Indicator.open()

    downloadLatestApk = =>
        data.screencap = false
        data.downloadingApk = true
        data.downloadProgress = 0
        downloadTask()

    downloadTask = ->
        privateToken = 'VFuvYLhMUZgpp-sK_Ej6'

        progress request({
            url: 'http://10.0.10.211:9001/api/v3/projects/15/builds/artifacts/develop/download?job=publish',
            headers:
                'PRIVATE-TOKEN': privateToken
            })
        .on 'progress', (state) ->
            console.log state
            progress = state.percent
            data.downloadProgress = progress * 100
        .on 'end', ->
            data.downloadProgress = 100
        .pipe fs.createWriteStream("/tmp/a.zip")

    app = new Vue
        el: "#app"
        data: data
        methods:
            capture: capture
            downloadLatestApk: downloadLatestApk
            switchDevice: (event) =>
                $('.device.selected').removeClass "selected"
                $(event.target).addClass "selected"
                data.screencap = undefined

            aboutScreenCap: (event) ->
                dataUrl = $(event.target).attr 'src'
                ipc.send 'request-saveImage', dataUrl

        created: =>
            # `this` points to the vm instance
            ipc.send 'request-devices'


    ipc.on 'devices', (event, devices) =>
        data.devices = devices

    ipc.on 'screencap', (event, image) =>
        data.screencap = image;
        Indicator.close()

    ipc.on 'saveImage', (event, err) =>
        if err then alert '保存失败' else alert '保存成功'
