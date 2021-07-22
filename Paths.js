const { existsSync, writeFileSync } = require('fs');
const os = require('os');
const path = require('path');

const PathRoot = (process.env.PATH_ROOT || os.homedir()).replace(/\\/g, '/')

// Users
const UsersFile = path.resolve(PathRoot, '.HttpInjector.json');
if (!(existsSync(UsersFile))) writeFileSync(UsersFile, "{}");

// Tokens
const Tokens = path.resolve(PathRoot, '.HttpInjectorTokens.json');
if (!(existsSync(Tokens))) writeFileSync(Tokens, "[]");

// Users db
const UserDB = path.resolve(PathRoot, '.HttpInjectorDB.db');
if (!(existsSync(UserDB))) writeFileSync(UserDB, "");

// Exports
module.exports = {
    UsersFile,
    TokensFile: Tokens,
    UserDB,
}