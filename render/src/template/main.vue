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
                <el-screen class="tab-container show" />
                <el-apk class="tab-container" />
                <el-launch class="tab-container" />
            </div>
            <div class="toolbar">
                <button class="tab-btn" data-index="0" @click="switchTab">截图</button>
                <button class="tab-btn" data-index="1" @click="switchTab">安装</button>
                <button class="tab-btn" data-index="2" @click="switchTab">启动应用</button>
            </div>
        </div>
    </div>
</template>

<script>
    import {ipcRenderer as ipc} from 'electron'
    import * as $ from 'jquery'
    import {Progress, MessageBox, Indicator} from 'mint-ui'
    import Screen from './screen.vue'
    import Apk from './apk.vue'
    import Launch from './launch.vue'

    export default {
        name: 'app',
        data () {
            return {
                devices: [],

            }
        },
        components: {
            'el-screen': Screen,
            'el-apk': Apk,
            'el-launch': Launch
        },
        methods: {
            switchTab (event) {
                var index = $(event.target).data("index");
                var el = $('.tab-container').get(index)
                $('.tab-container.show').removeClass("show");
                $(el).addClass("show");
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
        }
    }
</script>

<style lang="less">
    .content {
        position: relative;
    }
    .toolbar {
        width: 100%;
        background: grey;
        display: flex;
    }
    .tab-container {
        display: none;
        position: absolute;
        text-align: center;
        width: calc(~'100% - 2rem');
        height: calc(~'100% - 2rem');
    }
    .show {
        display: block;
    }

    .content {
        text-align: center;
        display: flex;
        flex-direction: column;
    }

    .content-container {
        padding: 1rem;
        flex: 1;
        position: relative;
    }

    .toolbar > button {
        background: transparent;
        color: white;
        outline: none;
        border: none;
        font-size: .9rem;
        flex: 1;
        padding: 10px 0;

        &:hover {
            background: rgba(255, 255, 255, 0.3);
        }
    }
</style>

