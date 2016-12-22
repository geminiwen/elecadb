window.jQuery = $ = require 'jquery'
require './../../assets/javascript/bootstrap.min'
mintUI = require './../../assets/javascript/mint-ui'
Vue = require './../../assets/javascript/vue'
fs = require 'fs'
Promise = require 'bluebird'
Progress = require 'progress-stream'
temp = require 'temp'
ipc = require('electron').ipcRenderer
debug = require('debug') 'render'
request = require 'request'
unzip = require 'unzip'
path = require 'path'
os = require 'os'

{Indicator, MessageBox} = mintUI
{remote} = require 'electron'
{Menu, MenuItem, dialog, nativeImage} = remote

temp.track()

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
            return

        ipc.send 'request-screencap', id
        Indicator.open()

    prepareDownloadApk = ->
        id = $('.device.selected').data 'device'
        if !id
            MessageBox 'FBI Warning', '你没有选择设备或者设备没有连接好!'
            return

        data.downloadProgress = 0
        $('#download-box').show()
        $('#download-tip').text '正在下载...'

        progress = Progress {time: 100}
        .on 'progress', (state) ->
            data.downloadProgress = state.percentage
        .on 'error', (err) ->
            console.error err
            $('#download-box').hide()
            MessageBox 'FBI Warning', '下载失败,请检查网络'
        .on 'end', ->
            $('#download-tip').text '下载完成'
            data.downloadProgress = 100

        mkdir = Promise.promisify(temp.mkdir)

        mkdir 'temp'
        .then (path) ->
            realDownloadApk path, progress
        .then (apkPath) ->
            $('#download-tip').text '正在安装'
            Indicator.open()
            ipc.send 'request-installApk', id, apkPath
        .catch (err) ->
            $('#download-box').hide()
            MessageBox 'FBI Warning', '下载失败,请检查网络'


    realDownloadApk = (dirPath, progress) ->
        console.log dirPath
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



    app = new Vue
        el: "#app"
        data: data
        methods:
            capture: capture
            downloadLatestApk: prepareDownloadApk
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

    ipc.on 'installApk', (event, err) =>
        Indicator.close()
        if err
            alert '安装失败'
            return

        alert '安装成功'
        $('#download-box').hide()
