<template>
    <div>
        <div class="field"><input type="text" id="component" placeholder="Package Name/Component Name" /></div>
        <div class="field"><input type="text" id="activity" placeholder="Activity Name" /></div>
        <div class="field col-container" v-for="n in paramsCount">
            <div class="col-1">
                <input type="text" class="param_key" placeholder="Key" />
            </div>
            <div class="col-1">
                <input type="text" class="param_value" placeholder="Value" />
            </div>
            <div class="col-1">
                <select class="param_type">
                    <option value="string">string</option>
                    <option value="int">int</option>
                    <option value="long">long</option>
                    <option value="float">float</option>
                    <option value="bool">bool</option>
                    <option value="uri">uri</option>
                    <option value="null">null</option>
                </select>
            </div>
        </div>
        <div class="field">
            <button @click="addParam">增加一行</button>
            <button @click="launch">启动</button>
        </div>
    </div>
</template>
<script>
    import * as $ from 'jQuery'
    import {Progress, MessageBox, Indicator} from 'mint-ui'
    import {ipcRenderer as ipc} from 'electron'
    export default {
        data: function () {
            return {
                paramsCount: 1
            }
        },
        methods: {
            addParam() {
                if(this.paramsCount < 7) this.paramsCount ++;
            },
            launch() {
                let id = $('.device.selected').data('device')
                if (!id) {
                    MessageBox('FBI Warning', '你没有选择设备或者设备没有连接好!')
                    return;
                }

                let component = $('#component').val()
                let activity = $('#activity').val()
                let params = [];
                let paramsContainer = $('.col-container');
                for (let i = 0; i < this.paramsCount; i ++) {
                    let key = $(paramsContainer[i]).find(".param_key").val().trim(),
                        value = $(paramsContainer[i]).find(".param_value").val().trim(),
                        type = $(paramsContainer[i]).find(".param_type").val();
                    if (key == '') continue;
                    params.push({key, value, type: type})
                }


                ipc.send('request-launch', id, component, activity, params);
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
        }
    }
</script>
<style scoped>
    input[type="text"] {
        outline: none;
        padding: 0 15px;
        height: 30px;
        width: 100%;
        border-radius: 5px;
        border: 1px solid grey;
    }
    select {
        height: 30px;
        width: 100%;
    }

    .field {
        margin: 15px auto;
    }
    .field.col-container {
        display: flex;
        flex-direction: row;
    }
    .col-1 {
        flex: 1;
        margin: 0 5px;
    }
    .col-1:first-child {
        margin-left: 0;
    }
    .col-1:last-child {
        margin-right: 0;
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