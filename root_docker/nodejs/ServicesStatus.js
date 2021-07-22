const { execSync } = require("child_process")
function getJsonStatus() {
    const status = execSync("service --status-all 2>&1").toString().split(/\r?\n/g)
    let StatusArray = []
    for (let index of status) {
        index = index.split(/\[/g).join("").split(/\]/g).join("").trim()
        if (!(index === "" || index === "\n")) {
            index = index.split(/\s+/g)
            if (index[0] === "-") StatusArray[index[1]] = false
            else StatusArray[index[1]] = true
        }
    }
    return StatusArray
}
module.exports.status = getJsonStatus
