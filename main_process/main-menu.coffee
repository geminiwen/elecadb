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
},
    {
        label: 'View',
        submenu: [
            {
                role: 'reload'
            },
            {
                role: 'toggledevtools'
            },
            {
                type: 'separator'
            },
            {
                role: 'resetzoom'
            },
            {
                role: 'zoomin'
            },
            {
                role: 'zoomout'
            },
            {
                type: 'separator'
            },
            {
                role: 'togglefullscreen'
            }
        ]
    },
    {
        role: 'window',
        submenu: [
            {
                role: 'minimize'
            },
            {
                role: 'close'
            }
        ]
    },
]

app.on 'ready', ->
    menu = Menu.buildFromTemplate template
    Menu.setApplicationMenu menu