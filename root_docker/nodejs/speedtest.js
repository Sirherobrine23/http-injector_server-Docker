console.log("The test started please wait")
const {writeFileSync} = require("fs");
const { execSync } = require('child_process');
const Response = JSON.parse(execSync(`speedtest-cli --json`))
console.log(Response);

var Download = Math.trunc(Response.download / 1000 / 100 / 7.5),
    Upload = Math.trunc(Response.upload / 1000 / 100 / 7.5),
    ping = Response.ping,
    isp = Response.client.isp,
    external_ip = Response.client.ip;

if (Download > 1000 && Upload > 1000) console.log(`Download: ${Download / 1000} Gbps, Upload: ${Upload / 1000} Gbps`)
else console.log(`Download: ${Download} Mbps, Upload: ${Upload} Mbps`);


writeFileSync("/tmp/speedteste.json", JSON.stringify({
    "download": Download,
    "upload": Upload,
    "ping": ping,
    "isp": isp,
    "ip": external_ip
}, null, 4))