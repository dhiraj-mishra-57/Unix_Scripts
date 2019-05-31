#!/bin/sh

#Check your export variables
export ORACLE_HOME=?
export LD_LIBRARY_PATH=?
export PATH=?
DB_User=USER_NAME
DB_Sid=DATABASE ID
Token=PASSWORD

path=script_path
file_path=file_where_script_will_be_Saved

tmp=$DB_User/$Token@$DB_Sid
. $path/Qc_Queries.sql     # Path to Query files

ZipFile_DSLS=$file_path/Qc_Extracts_DSLS
I_DSLS=$file_path/FILE1.csv
LD_DSLS=$file_path/FILE2.csv
LP_DSLS=$file_path/FILE3.csv

rm -rf $ZipFile_DSLS $I_DSLS $LD_DSLS $LP_DSLS   #Removing yesterday's file

sqlplus -s $tmp  << EOF
  SET COLSEP ','
  SET ECHO OFF
  SET FEEDBACK OFF
  SET TERMOUT OFF
  SET NEWPAGE NONE
  set pages 999
  set heading off
  set linesize 1000
  SET PAGESIZE 50
  SET TIMING OFF
  SPOOL $I_DSLS
  $ICS_NR_DSLS;
  SPOOL OFF
  SPOOL $LD_DSLS
  $LH_SD_DSLS;
  SPOOL OFF
  SPOOL $LP_DSLS
  $LH_SP_DSLS;
  SPOOL OFF
  exit
EOF

chmod 777 $I_DSLS $LD_DSLS $LP_DSLS
zip -r -j ${ZipFile_DSLS}.zip $I_DSLS $LD_DSLS $LP_DSLS

while read row
do
ICS_NR_7=`echo $row | awk -F "," '{ print $7}'| sed 's/  */ /g'`
# Checking if the 7th column of the file has "Match|Match Roundoff" if not then fail
# Using double quotes to preserve the variables
if [ "$ICS_NR_7" = "Match" ] || [ "$ICS_NR_7" = "Match Roundoff" ]       
then
:
else
echo "-->Failed Due to Daily_ICS Query<--"
exit 1
fi
done < $I_DSLS

echo "-->Daily_ICS Query has been Processed without any discrepancy<--"

while read row
do
LH_SD_8=`echo $row | awk -F "," '{ print $8}'| sed 's/  *//g'`
LH_SD_11=`echo $row | awk -F "," '{ print $11}' | sed 's/  */ /g'`
# Checking if the 8th & 11th column of the file has "Match|Match Roundoff" if not then fail
if ([ "$LH_SD_8" = "Match" ]) && ([ "$LH_SD_11" = "Match" ] || [ "$LH_SD_11" = "Match Roundoff" ])
then
:
else
echo "-->Failed Due to Daily_LH_SD Query<--"
exit 1
fi
done < $LD_DSLS

echo "-->Daily_LH_SD Query has been Processed without any discrepancy<--"

while read row
do
LH_SP_8=`echo $row | awk -F "," '{ print $8}'| sed 's/  *//g'`
LH_SP_11=`echo $row | awk -F "," '{ print $11}' | sed 's/  */ /g'`
# Checking if the 8th & 11th column of the file has "Match|Match Roundoff" if not then fail
if ([ "$LH_SP_8" = "Match" ]) && ([ "$LH_SP_11" = "Match" ] || [ "$LH_SP_11" = "Match Roundoff" ])
then
:
else
echo "-->Failed Due to Daily_LH_SP Query "
exit 1
fi
done < $LP_DSLS
echo "-->Daily_LH_SP Query has been Processed without any discrepancy"