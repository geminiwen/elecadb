window.jQuery = $ = require 'jquery'
require './../../assets/javascript/bootstrap.min'
mintUI = require './../../assets/javascript/mint-ui'
Vue = require './../../assets/javascript/vue'
{Indicator, MessageBox} = mintUI
{remote} = require 'electron'
fs = require 'fs'
Promise = require 'bluebird'
Progress = require 'progress-stream'
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

        privateToken = 'VFuvYLhMUZgpp-sK_Ej6'
        progress = Progress {time: 100}
        .on 'progress', (state) ->
            data.downloadProgress = state.percentage
        .on 'error', (err) ->
            console.error err
            MessageBox 'FBI Warning', '下载失败,请检查网络'
        .on 'end', ->
            $('#download-tip').text '下载完成'
            data.downloadProgress = 100

        request.get
            url: 'http://10.0.10.211:9001/api/v3/projects/15/builds/artifacts/develop/download?job=publish',
            headers:
                'PRIVATE-TOKEN': privateToken
        .on 'response', (res) ->
            #TODO: deal with statusCode
            progress.setLength parseInt(res.headers['content-length'])
        .on 'error', (err) ->
            console.error err
            MessageBox 'FBI Warning', '下载失败,请检查网络'
        .pipe progress
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
