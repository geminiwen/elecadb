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
            <div class="title-bar">Elecadb</div>
            <div class="content-container">


                <div id="download-box">
                    <span id="download-tip">正在下载APK....</span>
                    <mt-progress id="download-progress" :value="downloadProgress" :bar-height="10"></mt-progress>
                </div>

                <div v-if="screencap">
                    <img id="screencap" v-on:contextmenu="saveScreencap" :src="screencap"/>
                </div>
            </div>
            <div class="toolbar">
                <button @click="capture" :disabled="working">截图</button>
                <button @click="dowloadApk" :disabled="working">安装最新的APK</button>
                <button @click="startDebugActivity" :disabled="working">启动集成开发环境</button>
            </div>
        </div>
    </div>
</template>

<script>
    import fs from 'fs'
    import {ipcRenderer as ipc} from 'electron'
    import * as $ from 'jquery'
    import {Progress, MessageBox, Indicator, Button} from 'mint-ui'
    import progress from 'progress-stream'
    import Temp from 'temp'
    import Promise from 'bluebird'
    import path from 'path'
    import request from 'request'

    export default {
        name: 'app',
        data () {
            return {
                devices: [],
                screencap: undefined,
                downloadProgress: 0,
                working: false
            }
        },
        components: {
            'mt-progress': Progress,
            'mt-button': Button
        },
        methods: {
            capture() {
                let id = $('.device.selected').data('device')
                if (!id) {
                    MessageBox('FBI Warning', '你没有选择设备或者设备没有连接好!')
                    return;
                }
                this.working = true;
                ipc.send('request-screencap', id)
                Indicator.open();
                ipc.on('screencap', (event, err, image) => {
                    Indicator.close()
                    this.working = false;
                    if(err) {
                        MessageBox('FBI Warning', '截图失败')
                        return;
                    }
                    this.screencap = image;
                });
            },
            saveScreencap() {
                let dataUrl = $(event.target).attr('src')
                ipc.send('request-saveImage', dataUrl)
            },
            dowloadApk() {
                let id = $('.device.selected').data('device')
                if (!id) {
                    MessageBox('FBI Warning', '你没有选择设备或者设备没有连接好!')
                    return;
                }
                this.screencap = undefined;
                this.dataProgress = 0;
                this.working = true;
                $('#download-box').show()
                $('#download-tip').text('正在下载...')
                
                ipc.send('request-downloadApk');


                ipc.on('downloadApk', (event, err, subEvent, data) => {
                    if (err) {
                        this.working = false;
                        $('#download-box').hide();
                        this.dataProgress = 0;
                        ipc.removeAllListeners('downloadApk');
                        MessageBox('FBI Warning', '下载失败,请检查网络')
                        return;
                    }
                    
                    if (subEvent == 'progress') {
                        this.downloadProgress = data;   
                    } else if (subEvent == 'complete') {
                        ipc.removeAllListeners('downloadApk');
                        $('#download-tip').text('下载完成')
                        this.downloadProgress = 100;
                        ipc.send('request-installApk', id, data)
                        Indicator.open()

                        ipc.on('installApk', (event, err) => {
                             this.downloadProgress = 0;
                            ipc.removeAllListeners('installApk');
                            Indicator.close();
                            $('#download-box').hide();
                            this.working = false;
                                
                            if (err) {
                                MessageBox('FBI Warning', '安装失败');
                                return;
                            }
                            MessageBox('恭喜你', '安装成功啦！')
                        })
                    }
                });
            },
            startDebugActivity() {
                let id = $('.device.selected').data('device')
                if (!id) {
                    MessageBox('FBI Warning', '你没有选择设备或者设备没有连接好!')
                    return;
                }
                ipc.send('request-launch', id);
                Indicator.open();
                ipc.on('launch', (event, err) => {
                    ipc.removeAllListeners('launch');
                    Indicator.close();
                    if (err) {
                        MessageBox('FBI Warning', '启动失败');
                        return;
                    }
                })
            }
        },
        mounted() {
            ipc.send('request-devices');
            ipc.on('devices', (event, devices) => {
                this.devices = devices;
            });
            $('.toolbar').addClass("is-shown");
        }
    }
</script>

<style lang="less">
    .content {
        position: relative;
    }
    .toolbar {
        width: 100%;
        padding: 5px 0;
        background: grey;
        position: absolute;
        bottom: 0;
        left: 0;
    }
    #download-tip {
        font-size: 1rem;
    }
    button {
        background: #555;
        border: 1px solid #444;
        color: white;
        outline: none;
        font-size: .9rem;

        &:disabled {
            color: #666;
        }

        margin: .1rem .1rem;
    }
</style>

