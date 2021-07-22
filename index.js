const fs = require("fs");
const path = require("path");
const express = require("express");
const app = express();

// Set up the backend
const cors = require("cors");
const express_rate_limits = require("express-rate-limit");

app.use(cors());
app.use(express_rate_limits({
    windowMs: 6 * 60 * 1000,
}));

const StatusRestart = {
    Status: false,
    Date: null,
};
app.use(function (req, res, next) {
    if (StatusRestart.Status) {
        const File = fs.readFileSync("./html/Restart_Services.html", "utf8").split("{{DATE}}").join(StatusRestart.Date);
        return res.send(File);
    } else return next();
});

// Routes
app.all("/", ({res}) => res.sendFile(path.join(__dirname, "./html/index.html")));

// API
app.use("/api", require("./express/api"));

// Users
app.use("/users", require("./express/users"));

// services
app.use("/services", require("./express/services"));

// Listen
app.listen(8080, function() {  
    console.log("Listening on port 8080");
});