<template xmlns:v-on="http://www.w3.org/1999/xhtml" xmlns:v-bind="http://www.w3.org/1999/xhtml">
    <div id="app">
        <nav class="nav">
            <div v-if="devices.length">
                <h5>找到如下设备</h5>
                <ul>
                    <li v-bind:class="{ device: true, selected: index == 0 }" v-for="(device, index) in devices"
                        :data-device="device.id">{{ device.brand + ' ' + device.name }}
                    </li>
                </ul>
            </div>
            <div v-else>
                <h5>没有找到设备, 请检查手机连接</h5>
            </div>
        </nav>
        <div class="content is-shown">
            <div class="toolbar">
                <button class="btn btn-default" @click="capture">截图</button>
                <button class="btn btn-default" >安装最新的包</button>
            </div>

            <div id="download-box">
                <span id="download-tip">正在下载APK....</span>
                <mt-progress id="download-progress" :value="downloadProgress" :bar-height="10"></mt-progress>
            </div>

            <div v-if="screencap">
                <img id="screencap" v-on:contextmenu="aboutScreenCap" :src="screencap"/>
            </div>
        </div>
    </div>
</template>

<script>
    import fs from 'fs'
    import {ipcRenderer as ipc} from 'electron'
    import * as $ from 'jquery'
    import {Progress, MessageBox} from 'mint-ui'

    export default {
        name: 'app',
        data () {
            return {
                devices: [],
                screencap: undefined,
                downloadProgress: 0
            }
        },
        components: {
            'mt-progress': Progress
        },
        methods: {
            capture() {
                let id = $('.device.selected').data('device')
                MessageBox('FBI Warning', '你没有选择设备或者设备没有连接好!')
            }
        },
        mounted() {
            ipc.send('request-devices');
            ipc.on('devices', (event, devices) => {
                this.devices = devices;
            });
        }
    }
</script>