module.exports.test = function (){
    console.log("The test started please wait");
    const {writeFileSync} = require("fs");
    const { execSync } = require('child_process');
    var Response;
    try {
        Response = JSON.parse(execSync(`speedtest-cli --json`))
    } catch (error) {
        return {
            "download": 99999999,
            "bytetypedownload": "Kbps",
            "upload": 99999999,
            "bytetypeupload": "Kbps",
            "ping": 99999999,
            "isp": null,
            "ip": null
        }
    }
    var Download = Math.trunc(Response.download / 1000 / 100 / 7.5),
        Upload = Math.trunc(Response.upload / 1000 / 100 / 7.5),
        ping = Response.ping,
        isp = Response.client.isp,
        external_ip = Response.client.ip;

    var ByteDown, ByteUp
    if (Download > 1000) ByteDown = "Gbps"
    else ByteDown = "Mbps"
    
    if (Upload > 1000) ByteUp = "Gbps"
    else ByteUp = "Mbps"

    const result = {
        "download": Download,
        "bytetypedownload": ByteDown,
        "upload": Upload,
        "bytetypeupload": ByteUp,
        "ping": ping,
        "isp": isp,
        "ip": external_ip
    }
    writeFileSync("/tmp/speedteste.json", JSON.stringify(result, null, 4));
    return result
}