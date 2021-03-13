const speedTest = require('speedtest-net');
(async () => {
    try {
        const Speed = await speedTest({acceptLicense: true,acceptGdpr: true});
        const Download = Math.trunc(Speed.download.bandwidth / 1000 / 100),
            Upload = Math.trunc(Speed.upload.bandwidth / 1000 / 100);
        if (Download < 1000 && Upload < 1000) console.log(`Download: ${Download / 1000} Gbps, Upload: ${Upload / 1000} Gbps`);
        else console.log(`Download: ${Download} Mbps, Upload: ${Upload} Mbps`);
        
    }
    /* catch (err) {
        console.log(err.message);
    } */
    finally {
        process.exit(0);
    }
})();