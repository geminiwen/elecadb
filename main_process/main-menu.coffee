{BrowserWindow, Menu, app} = require 'electron'

template = [{
    label: app.getName(),
    submenu: [{
        label: 'Settings',
        click: () ->
            settings = new BrowserWindow({
                width: 200,
                height: 200,
                resizable: false,
                title: 'Settings'
            })
    }]
}]

app.on 'ready', ->
    menu = Menu.buildFromTemplate template
    Menu.setApplicationMenu menu