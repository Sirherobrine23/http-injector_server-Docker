#!/usr/bin/env node
const express = require("express");
const fs = require("fs");
const path = require("path");
var cors = require("cors");
const bodyParser = require("body-parser");

function api(port_api){
    const app = express();
    app.use(fileUpload({limits: { fileSize: 512 * 1024 }}));
    app.use(cors());
    app.use(bodyParser.json()); /* https://github.com/github/fetch/issues/323#issuecomment-331477498 */
    app.use(bodyParser.urlencoded({ extended: true }));
    app.use(rateLimit({windowMs: 15 * 60 * 1000, /* 15 minutes */ max: 1000 /* limit each IP to 100 requests per windowMs */}));
    // -----------------------------

    // -----------------------------
    const port = (port_api||1112)
    app.listen(port, function (){
        console.log(`Web Config: ${port}`);
    });
    return port
}