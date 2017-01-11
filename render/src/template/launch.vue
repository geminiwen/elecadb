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
        </div>
        <div class="field">
            <button @click="addParam">增加一行</button>
            <button @click="launch">启动</button>
        </div>
    </div>
</template>
<script>
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
                var component = $('#component').val()
                var activity = $('#activity').val()
                var params = {};

                for (let i in this.paramsCount) {

                }

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