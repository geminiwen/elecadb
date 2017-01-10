{BrowserWindow, Menu, app} = require 'electron'
url = require 'url'
path = require 'path'


settings = null

template = [{
    label: app.getName(),
    submenu: [{
        label: 'Settings',
        click: () ->
            if settings then return

            settings = new BrowserWindow({
                width: 300,
                height: 200,
                resizable: false,
                title: 'Settings'
            })

            settings.loadURL(url.format({
                pathname: path.join(__dirname, '../render/settings.html'),
                protocol: 'file:',
                slashes: true
            }));

            settings.on 'closed', () ->
                settings = null
    }]
},
{
    label: 'Edit',
    submenu: [
        {
            role: 'selectall',
        }
        {
            role: 'cut',
        }
        {
            role: 'copy'
        },
        {
            role: 'paste'
        }
    ]
}
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