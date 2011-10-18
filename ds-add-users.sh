#!/bin/sh

_DB_BYHOST="/Volumes/Server_HD_2/Databases/ByHost"
_HOST_MAC=70cd608d64b2
_HOST_USER_NAME=testinguser
_HOST_USER_PASSWORD=newpassword
_HOST_USER_SHORTNAME=testinguser

_DS_USERS="({\"dstudio-user-admin-status\" = YES; \"dstudio-user-name\" = ${_HOST_USER_NAME}; \"dstudio-user-password\" = \"${_HOST_USER_PASSWORD}\"; \"dstudio-user-shortname\" = ${_HOST_USER_SHORTNAME};})"
echo defaults write ${_DB_BYHOST}/${_HOST_MAC} dstudio-users "${_DS_USERS}"
