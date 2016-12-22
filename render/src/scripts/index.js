import '../stylesheet/variable.css'
import '../stylesheet/global.css'
import '../stylesheet/index.css'
import Vue from 'vue'
import App from '../template/main.vue'


var app = new Vue({
    el: '#app',
    render: (h) => h(App)
})

