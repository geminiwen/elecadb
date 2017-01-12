<template xmlns:v-on="http://www.w3.org/1999/xhtml">
    <div>
        <button id="download-btn" @click="downloadApk">下载 & 安装 APK</button>
        <div id="download-box">
            <span id="download-tip">正在下载APK....</span>
            <mt-progress id="download-progress" :value="downloadProgress" :bar-height="10"></mt-progress>
        </div>
    </div>
</template>
<script>
    import {Progress, MessageBox, Indicator, Button} from 'mint-ui'
    import {ipcRenderer as ipc} from 'electron'
    import * as $ from 'jquery'
    export default {
        name: 'apk',
        data() {
            return {
                'downloadProgress': 0
            }
        },
        components: {
            'mt-progress': Progress,
        },
        methods: {
            downloadApk() {
                let id = $('.device.selected').data('device')
                if (!id) {
                    MessageBox('FBI Warning', '你没有选择设备或者设备没有连接好!')
                    return;
                }
                $('#download-box').show();
                this.downloadProgress = 0;
                $('#download-tip').text('正在下载...')

                ipc.send('request-downloadApk');

                ipc.on('downloadApk', (event, err, subEvent, data) => {
                    if (err) {
                        console.dir(err);
                        $('#download-box').hide();
                        this.downloadProgress = 0;
                        ipc.removeAllListeners('downloadApk');
                        if (err == 'settings') {
                            MessageBox('字段空缺', '请先在设置页面填好 Fir API Token')
                        } else {
                            MessageBox('FBI Warning', '下载失败,请检查网络')
                        }
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

                            if (err) {
                                MessageBox('FBI Warning', '安装失败');
                                return;
                            }
                            MessageBox('恭喜你', '安装成功啦！')
                        })
                    }
                });
            },
        }
    }
</script>


<style scoped>
    #download-btn {
        margin-bottom: 1rem;
    }

    #download-tip {
        font-size: 1rem;
    }

    #download-box {
        display: none;
    }

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