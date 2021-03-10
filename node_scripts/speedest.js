const speedTest = require('speedtest-net');
(async () => {
    try {
        const Speed = await speedTest({acceptLicense: true,acceptGdpr: true});
        const Download = Math.trunc(Speed.download.bandwidth / 1000 / 100),
            Upload = Math.trunc(Speed.upload.bandwidth / 1000 / 100);
        const doS = `Download: ${Download} Mbps, Upload: ${Upload} Mbps`
        const Uplaod_log =  (Upload) => {console.log("Mais de "+Upload+" usuarios podem se conectar ao servidor")};
        if (Upload > 10) Uplaod_log(10)
        console.log(doS);
    }
    /* catch (err) {
        console.log(err.message);
    } */
    finally {
        process.exit(0);
    }
})();