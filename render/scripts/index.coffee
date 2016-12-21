mintUI = require './../../assets/javascript/mint-ui'
Vue = require './../../assets/javascript/vue'
Indicator = mintUI.Indicator

$ = require 'jquery'
window.jQuery = $
require('./../../assets/javascript/bootstrap.min')

ipc = require('electron').ipcRenderer
debug = require('debug') 'render'

document.addEventListener "DOMContentLoaded", =>
    Vue.use mintUI

    data =
        devices: [],
        screencap: undefined

    capture = =>
        id = $('.device.selected').data 'device'
        if id is no
            $('.alert').show()
        else
            ipc.send 'request-screencap', id
            Indicator.open()

    downloadFromFir = =>

    app = new Vue
        el: "#app"
        data: data
        methods:
            capture: capture
            downloadFromFir: downloadFromFir
            switchDevice: (event) =>
                $('.device.selected').removeClass "selected"
                $(event.target).addClass "selected"
        created: =>
            # `this` points to the vm instance
            ipc.send 'request-devices'



    ipc.on 'devices', (event, devices) =>
        console.log devices
        data.devices = devices

    ipc.on 'screencap', (event, image) =>
        data.screencap = image;
        Indicator.close()