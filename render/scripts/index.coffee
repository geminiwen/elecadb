window.jQuery = $ = require 'jquery'
require './../../assets/javascript/bootstrap.min'
mintUI = require './../../assets/javascript/mint-ui'
Vue = require './../../assets/javascript/vue'
{Indicator, MessageBox} = mintUI
{remote} = require 'electron'
fs = require 'fs'
Progress = require 'progress-stream'
Promise = require 'bluebird'


{Menu, MenuItem, dialog, nativeImage} = remote
temp = require 'temp'

ipc = require('electron').ipcRenderer
debug = require('debug') 'render'

document.addEventListener "DOMContentLoaded", =>
    Vue.use mintUI

    data =
        devices: [],
        screencap: undefined,
        downloadProgress: 0

    capture = =>
        id = $('.device.selected').data 'device'
        if !id
            MessageBox 'FBI Warning', '你没有选择设备或者设备没有连接好!'
        else
            ipc.send 'request-screencap', id
            Indicator.open()

    downloadLatestApk = =>
        data.downloadProgress = 0
        $('#download-box').show()
        $('#download-tip').text '正在下载...'

        ipc.send 'request-downloadApk'


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
