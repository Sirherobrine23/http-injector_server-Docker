const data = process.env.teste
const base = new Buffer.from(data).toString("base64")
console.log(`Base64: ${base}`)

const text = new Buffer.from(base, 'base64').toString('ascii');
console.log(`Decode: ${text}`)