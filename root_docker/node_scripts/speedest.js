const speedTest = require('speedtest-net');
console.log("The test started please wait")
const {writeFileSync} = require("fs")
speedTest({acceptLicense: true,acceptGdpr: true}).then(Response => {
    const Download = Math.trunc(Response.download.bandwidth / 1000 / 100),
        Upload = Math.trunc(Response.upload.bandwidth / 1000 / 100);
    console.log(`You IP: ${Response.server.ip}, Interface that was used for the test: ${Response.interface.name}, internal ip: ${Response.interface.internalIp}`)
    console.log(`Ping: ${Response.ping.latency}ms, ISP: ${Response.isp}`);
    if (Download > 1000 && Upload > 1000) console.log(`Download: ${Download / 1000} Gbps, Upload: ${Upload / 1000} Gbps`)
    else console.log(`Download: ${Download} Mbps, Upload: ${Upload} Mbps`)
    writeFileSync("/tmp/speedteste.json", JSON.stringify({
        "download": Download,
        "upload": Upload,
        "ping": Response.ping.latency,
        "isp": Response.isp
    }, null, 4))
})