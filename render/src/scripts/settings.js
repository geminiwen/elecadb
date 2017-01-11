require ("../stylesheet/global.css")
require ("../stylesheet/settings.css")
const storage = require('electron-json-storage')
const $ = require("jQuery")

$(document).ready(function () {
    $('#save').click(() => {
        let data = {
            "personalToken" : $('#personal_token').val(),
            "projectId" : $('#project_id').val()

        }

        storage.set("project", data, (err) => {
            if (err) {
                alert("保存失败");
                return;
            }
            alert("保存成功");
            window.close();
        });

    });

    storage.get("project", (err, data) => {
        if (err) {
            return;
        }
        $('#personal_token').val(data.personalToken);
        $('#project_id').val(data.projectId);
    })

});
