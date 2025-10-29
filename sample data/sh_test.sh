#!/bin/sh

# Please add all dependent JAR files to the CLASSPATH. 
# For example, when you use custom SerDe add their JAR files, as they are required by Hive's "show tables" command.
# Exqample: hive> ADD JAR /home/somefolder/dependent.jar;

start=$(date +"%s")

echo "-------------------------------------------------------------------------------" > tables.hql
echo "-- started - $(date +%F_%T)" >> tables.hql

SCHEMAS=$*

if [ -z "${SCHEMAS}" ]
then
  echo "Retrieving schemas ..."
  SCHEMAS=`hive -e "show databases;" 2>/dev/null | grep -v "WARN:"`
fi

HIVE_CMD=$(mktemp hive-XXXXXXXX.cmd)
for SCHEMA in ${SCHEMAS}
do
	echo "Processing '${SCHEMA}'"
	TABLES=`hive -e "show tables in ${SCHEMA}" 2>/dev/null | grep -v "WARN:"`
	for TABLE in ${TABLES}
	do
		echo "show create table ${SCHEMA}.${TABLE};" >> "${HIVE_CMD}"
	done
done

echo "Generating HQL ..."

hive -f "${HIVE_CMD}" 2>/dev/null | grep -v "WARN:" | sed 's/^CREATE /;\nCREATE /' >> tables.hql

rm "${HIVE_CMD}"

stop=$(date +"%s")

diff=$(( $stop - $start ))
echo "-- finished - $(date +%F_%T) ($diff sec)" >> tables.hql


