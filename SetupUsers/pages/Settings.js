function SaveUserinJson(){
    let UsernameConfig = JSON.parse(document.getElementById("outputJson").innerHTML)
    addRemoveUser(UsernameConfig)
    document.getElementById("saveUserButtom").setAttribute("disabled", null);
    document.getElementById("pass").value = ""
    document.getElementById("data").value = ""
    document.getElementById("connections").value = 1
    document.getElementById("outputJson").innerHTML = JSON.stringify({})
}
function PublishJson(){
    for (let index of jsonConfig.users){
        if (document.getElementById("user").value === index.user) return document.getElementById("saveUserButtom").setAttribute("disabled", null);
        document.getElementById("saveUserButtom").removeAttribute("disabled")
    }
    let JsonFile = {}
    JsonFile.user = (document.getElementById("user").value||"usertest")
    JsonFile.pass = btoa((document.getElementById("pass").value||"teste12"))
    let data = (document.getElementById("data").value||`${new Date().getFullYear()}-${new Date().getMonth()}-${new Date().getDate()}`).split("-")
    JsonFile.data = `${data[2]}/${data[1]}/${data[0]}`
    document.getElementById("diasrestantes").innerHTML = "Days Remaining: "+restdate(JsonFile.data)
    JsonFile.ssh = (parseInt(document.getElementById("connections").value)||1)
    document.getElementById("outputJson").innerHTML = JSON.stringify(JsonFile, null, 2)
}

function addRemoveUser(jsonUser) {
    var testUser = true
    if (jsonConfig.users.length !== 0) for (let index of jsonConfig.users) if (index.user === jsonUser.user) testUser = false
    if (testUser) jsonConfig.users.push(jsonUser);
    
    const numberRemove = jsonConfig.users.length - 1
    const divRemove = document.createElement("a")
    const divBase = document.createElement("div")
    const spanTex = document.createElement("span")
    
    spanTex.innerHTML = "&#8855;"

    divRemove.classList.add("userremove")
    divRemove.onclick = function () {
        jsonConfig.users.pop(numberRemove);
        divBase.remove();
    };
    divRemove.appendChild(spanTex)

    divBase.id = `Username_${numberRemove}`
    divBase.classList.add("usernameArea")
    divBase.innerHTML += `${jsonConfig.users.length}, ${jsonUser.user} `
    divBase.appendChild(divRemove)

    if (document.getElementById(`Username_${numberRemove}`) === null) document.getElementById("removeUser").appendChild(divBase);
    else console.log(document.getElementById(`Username_${numberRemove}`));
}

function restdate(d){
    const date1 = d.split("/")
    // date1[1] // Month
    // date1[0] // day
    // date1[2] // year
    const current_day = new Date().getDate()
    const current_month = new Date().getMonth()
    const current_year = new Date().getFullYear()

    const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
    const firstDate = new Date(date1[2], date1[1] - 1, date1[0]);
    const secondDate = new Date(current_year, current_month, current_day);
    const result = ((firstDate - secondDate) / oneDay)
    if (result < 0) return 0
    else return Math.round(Math.abs(result));
}
function opensshAdd(){
    const port = parseInt(document.getElementById("portOpenSSH").value)
    for (let index of jsonConfig.openssh.ports) if (parseInt(index) === port) return false;
    for (let index of jsonConfig.dropebear.ports) if (parseInt(index) === port) return false;
    for (let index of jsonConfig.squid.ports) if (parseInt(index) === port) return false;
    jsonConfig.openssh.ports.push(port)
    document.getElementById("portOpenSSH").value = ""
    const divRemove = document.createElement("a")
    const divBase = document.createElement("div")
    const spanTex = document.createElement("span")
    
    spanTex.innerHTML = "&#8855;"

    divRemove.classList.add("portremove")
    divRemove.onclick = function () {
        jsonConfig.openssh.ports.pop(port);
        divBase.remove();
    };
    divRemove.appendChild(spanTex)

    divBase.id = `Openssh_${port}`
    divBase.classList.add("portarea")
    divBase.innerHTML += `Port ${jsonConfig.openssh.ports.length}: ${port}`
    divBase.appendChild(divRemove)

    document.getElementById("opensshportarea").appendChild(divBase)
    return true
}

function dropbearAdd(){
    const port = parseInt(document.getElementById("portdropbear").value)
    for (let index of jsonConfig.openssh.ports) if (parseInt(index) === port) return false;
    for (let index of jsonConfig.dropebear.ports) if (parseInt(index) === port) return false;
    for (let index of jsonConfig.squid.ports) if (parseInt(index) === port) return false;
    jsonConfig.dropebear.ports.push(port)
    document.getElementById("portdropbear").value = ""
    const divRemove = document.createElement("a")
    const divBase = document.createElement("div")
    const spanTex = document.createElement("span")
    
    spanTex.innerHTML = "&#8855;"

    divRemove.classList.add("portremove")
    divRemove.onclick = function () {
        jsonConfig.dropebear.ports.pop(port);
        divBase.remove();
    };
    divRemove.appendChild(spanTex)

    divBase.id = `dropbear_${port}`
    divBase.classList.add("portarea")
    divBase.innerHTML += `Port ${jsonConfig.dropebear.ports.length}: ${port}`
    divBase.appendChild(divRemove)

    document.getElementById("dropbearportarea").appendChild(divBase);
    return true
}

function squidAdd(){
    const port = parseInt(document.getElementById("portsquid").value)
    for (let index of jsonConfig.openssh.ports) if (parseInt(index) === port) return false;
    for (let index of jsonConfig.dropebear.ports) if (parseInt(index) === port) return false;
    for (let index of jsonConfig.squid.ports) if (parseInt(index) === port) return false;
    jsonConfig.squid.ports.push(port)
    document.getElementById("portsquid").value = ""
    const divRemove = document.createElement("a")
    const divBase = document.createElement("div")
    const spanTex = document.createElement("span")
    
    spanTex.innerHTML = "&#8855;"

    divRemove.classList.add("portremove")
    divRemove.onclick = function () {
        jsonConfig.squid.ports.pop(port);
        divBase.remove();
    };
    divRemove.appendChild(spanTex)

    divBase.id = `squid_${port}`
    divBase.classList.add("portarea")
    divBase.innerHTML += `Port ${jsonConfig.squid.ports.length}: ${port}`
    divBase.appendChild(divRemove)
    document.getElementById("squidportarea").appendChild(divBase)
    return true
}

function sendConfig() {
    if (jsonConfig.openssh.ports.length === 0) return alert("Set ports to OpenSSH")
    if (jsonConfig.dropebear.ports.length === 0) return alert("Set ports to Dropbear")
    if (jsonConfig.squid.ports.length === 0) return alert("Set ports to Squid")
    if (jsonConfig.users.length === 0) return alert("Set users.")
    fetch("/save_config", {
        mode: "cors",
        method: "POST",
        headers: {
            token: token,
            injectorconfig: btoa(JSON.stringify(jsonConfig)).toString()
        }
    }).then(res => res.text()).then(res => {
        if (!(res === "ok")) throw Error(res)
    })
}
console.log(jsonConfigFromServer);
for (let index of jsonConfigFromServer.openssh.ports) {
    document.getElementById("portOpenSSH").value = index
    document.getElementById("addsshPort").click()
}
for (let index of jsonConfigFromServer.dropebear.ports) {
    document.getElementById("portdropbear").value = index
    document.getElementById("addDropPort").click()
}
for (let index of jsonConfigFromServer.squid.ports) {
    document.getElementById("portsquid").value = index
    document.getElementById("addSquidPort").click()
}
for (let index of jsonConfigFromServer.users) addRemoveUser(index)
