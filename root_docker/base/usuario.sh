#!/bin/bash
{
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password);
    useradd -m -p "$pass" "$username";
    addgroup ${username} sudo;
    usermod --shell /usr/bin/zsh --home /tmp/${username} ${username}
    echo "${username}   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
} &> /tmp/config_user

cd /node_scripts/
node set_users.js
