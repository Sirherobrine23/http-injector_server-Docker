const express = require("express");
const app = express.Router();
const path = require("path");
const fs = require("fs");
const { Speedtest } = require("../Backend")

app.all("/", ({res}) => res.send("API REST"));

// Speedtest
global.SpeedtestResult = {
    Date: new Date(),
    Speedtest_Result: {
        ping: null,
        downloadSpeed: null,
        uploadSpeed: null,
        pingUnit: "ms",
        downloadUnit: "Bps",
        uploadUnit: "Bps"
    },
    Ip_Result: {
        ip: null,
        city: null,
        region: null,
        country: null,
        loc: null,
        org: null,
        postal: null,
        timezone: null
    }
};
setInterval(async () => global.SpeedtestResult = await Speedtest(), 1 * 30 * 60 * 60 * 1000);
(async () => global.SpeedtestResult = await Speedtest())()
app.get("/speedtest", async ({res}) => res.json(global.SpeedtestResult));

app.all("*", ({res}) => res.sendStatus(404))

module.exports = app;