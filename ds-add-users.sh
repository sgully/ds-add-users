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
      plist = $1;
      admin = $2
      username = $3;
      password = $4;
      shortname = $5;
      hostname = $6;
      group = $7;

      # DEBUG
#      admin = "YES";
#      username = "JanaDIMITROPOULOS";
#      password = "UXFSckx4dE9aV2s9";
#      shortname = "s127044";
#      hostname = "janadimitropoulos";
#      group = "stu2014";

      gsub(/:/, "", plist); # strip colons for filename
      mac_addr = substr(plist, 1, 2);
      for (i = 1; i<6; i++) {
        mac_addr = sprintf("%s:%s", mac_addr, substr(plist, 1 + (i*2), 2))
      }

      defcom = sprintf("defaults write %s/%s ", _db_byhost, plist);

      printf("%s dstudio-users \047({", defcom);
      printf(" dstudio-user-admin-status = %s;", admin);
      printf(" dstudio-user-hidden-status = YES;");
      printf(" dstudio-user-name = %s;", username);
      printf(" dstudio-user-password = \"%s\";", password);
      printf(" dstudio-user-shortname = %s;", shortname);
      printf(" })\047\n");

      printf("%s dstudio-hostname \047%s\047\n", defcom, hostname);
      printf("%s dstudio-group \047%s\047\n", defcom, group);
      printf("%s architecture \047%s\047\n", defcom, "i386");
      printf("%s dstudio-auto-disable  \047%s\047\n", defcom, "NO");
      printf("%s dstudio-auto-reset-workflow  \047%s\047\n", defcom, "NO");
      printf("%s dstudio-disabled \047%s\047\n", defcom, "NO");
      printf("%s dstudio-mac-addr \047%s\047\n", defcom, mac_addr);
      printf("%s dstudio-clear-text-passwords \047%s\047\n", defcom, "YES");

      # Additional fields

      printf("%s architecture \047%s\047\n", defcom, "i386");
      printf("%s dstudio-auto-disable \047%s\047\n", defcom, "NO");
      printf("%s dstudio-auto-reset-workflow \047%s\047\n", defcom, "NO");
#      printf("%s dstudio-auto-started-workflow \047%s\047\n", defcom, "940CA56B-6A81-4BE7-9EA5-EE16BEA463B3");
      printf("%s dstudio-clear-text-passwords \047%s\047\n", defcom, "YES");
      printf("%s dstudio-disabled \047%s\047\n", defcom, "NO");
      printf("%s dstudio-group \047%s\047\n", defcom, "stu2014");
      printf("%s dstudio-host-ard-ignore-empty-fields \047%s\047\n", defcom, "NO");
      printf("%s dstudio-host-delete-other-locations \047%s\047\n", defcom, "NO");

      printf("%s dstudio-host-interfaces \047%s", defcom, "{");
      printf(" en0 = { ");
      printf(" dstudio-dns-ips = \"%s\"; ", "");
      printf(" dstudio-host-airport = \"%s\"; ", "NO");
      printf(" dstudio-host-airport-name = \"%s\"; ", "");
      printf(" dstudio-host-airport-password = \"%s\"; ", "");
      printf(" dstudio-host-ftp-proxy = \"%s\"; ", "NO");
      printf(" dstudio-host-ftp-proxy-port = \"%s\"; ", "");
      printf(" dstudio-host-ftp-proxy-server = \"%s\"; ", "");
      printf(" dstudio-host-http-proxy = \"%s\"; ", "NO");
      printf(" dstudio-host-http-proxy-port = \"%s\";", "");
      printf(" dstudio-host-http-proxy-server = \"%s\"; ", "");
      printf(" dstudio-host-https-proxy = \"%s\"; ", "NO");
      printf(" dstudio-host-https-proxy-port = \"%s\"; ", "");
      printf(" dstudio-host-https-proxy-server = \"%s\"; ", "");
      printf(" dstudio-host-interfaces = \"%s\"; ", "en0");
      printf(" dstudio-host-ip = \"%s\"; ", "");
      printf(" dstudio-router-ip = \"%s\"; ", "");
      printf(" dstudio-search-domains = \"%s\"; ", "");
      printf(" dstudio-subnet-mask = \"%s\"; ", "");
      printf("};}\047\n");

#    "dstudio-host-model-identifier" = "MacBook7,1";
#    "dstudio-host-new-network-location" = NO;
#    "dstudio-host-serial-number" = 4514405YF5W;
   }'
}

printf "\nStarting: `date`\n" | tee -a ${_LOG_FILE}
for f in $_CSV_FILES ; do
    if test -s $f ; then
	printf "\n Processing $f :\n"
	cat $f | read_csv_file | /bin/sh
	printf " Completed processing $f\n"
    else
	printf " Error - input file $f either does not exist or is empty.\n"
    fi
done 2>&1 | tee -a ${_LOG_FILE}
printf "\nEnding: `date`\n" | tee -a ${_LOG_FILE}

printf "\nThe output of this script has been logged to ${_LOG_FILE}\n"
