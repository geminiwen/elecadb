<template xmlns:v-on="http://www.w3.org/1999/xhtml">
    <div>
        <button id="screen-cap" @click="capture">截图</button>

        <div v-if="screencap">
            <img id="screencap" v-on:contextmenu="saveScreencap" :src="screencap"/>
        </div>

    </div>
</template>
<script>
    import {Progress, MessageBox, Indicator, Button} from 'mint-ui'
    import {ipcRenderer as ipc} from 'electron'
    import * as $ from 'jquery'
    export default {
        name: 'screen-cap',
        data() {
            return {
                "screencap": undefined
            }
        },
        methods: {
            capture() {
                let id = $('.device.selected').data('device')
                if (!id) {
                    MessageBox('FBI Warning', '你没有选择设备或者设备没有连接好!')
                    return;
                }
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
            }
        }
    }
</script>
<style scoped>
    button {
        border: none;
        color: white;
        background: #009A61;
        padding: 0 16px;
        height: 36px;
        line-height: 36px;
        font-size: 14px;
        min-width: 64px;
        outline: none;
        border-radius: .2rem;
    }
</style>