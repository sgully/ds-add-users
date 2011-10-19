#!/bin/sh

if test $# -lt 1 ; then
    echo "usage: `basename $0` file ..."
    exit 1
fi

_CSV_FILES="$*"
_DB_BYHOST="/Volumes/Server_HD_2/Databases/ByHost"
_LOG_FILE="`basename $0 .sh`.log"

## ------------------------------------------------------------
## CSV Format
##
## 1 = MAC
## 2 = dstudio-users-admin-status, (YES or NO)
## 3 = dstudio-users-name,
## 4 = dstudio-user-password,
## 5 = dstudio-user-shortname
## 6 = dstudio-hostname
## 7 = dstudio-group
##
## and dstudio-users-hidden-status is set to NO by default.
## ------------------------------------------------------------

read_csv_file() {
    awk -F, -v "_db_byhost=${_DB_BYHOST}" '{
      gsub(/\015/, "");       # strip CR
      gsub(/"* *, *"*/, ","); # simplify field separation
      gsub(/^ *" */, "");     # strip leading space and quote
      gsub(/"* *$/, "");      # strip trailing space and quote
      printf("defaults write %s/%s ", _db_byhost, $1);
      printf(" dstudio-users \047{");
      printf(" dstudio-users-admin-status = %s;", $2);
      printf(" dstudio-users-hidden-status = NO;");
      printf(" dstudio-users-name = %s;", $3);
      printf(" dstudio-user-password = \"%s\";", $4);
      printf(" dstudio-user-shortname = %s;", $5);
      printf(" }\047\n");
      printf("defaults write %s/%s ", _db_byhost, $1);
      printf(" dstudio-hostname  \047%s\047\n", $6);
      printf("defaults write %s/%s ", _db_byhost, $1);
      printf(" dstudio-group  \047%s\047\n", $7);
   }'
}

printf "\nStarting: `date`\n" | tee -a ${_LOG_FILE}
for f in $_CSV_FILES ; do
    if test -s $f ; then
	printf "\n Processing $f :\n"
	cat $f | read_csv_file #| /bin/sh
	printf " Completed processing $f\n"
    else
	printf " Error - input file $f either does not exist or is empty.\n"
    fi
done 2>&1 | tee -a ${_LOG_FILE}
printf "\nEnding: `date`\n" | tee -a ${_LOG_FILE}

printf "\nThe output of this script has been logged to ${_LOG_FILE}\n"
