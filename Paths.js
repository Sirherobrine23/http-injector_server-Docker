const { existsSync, writeFileSync } = require('fs');
const os = require('os');
const path = require('path');

// Users
const UsersFile = path.resolve(os.homedir(), '.HttpInjector.json');
if (!(existsSync(UsersFile))) writeFileSync(UsersFile, "{}");

// Tokens
const Tokens = path.resolve(os.homedir(), '.HttpInjectorTokens.json');
if (!(existsSync(Tokens))) writeFileSync(Tokens, "[]");

// Users db
const UserDB = path.resolve(os.homedir(), '.HttpInjectorTokens.json');
if (!(existsSync(UserDB))) writeFileSync(UserDB, "");

// Exports
module.exports = {
    UsersFile,
    TokensFile: Tokens,
    UserDB,
}