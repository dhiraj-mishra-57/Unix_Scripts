# Unix_Scripts
In this folder i have my unix script which is useful to run query using SQLPLUS command.

# QC_Validation.sh - 
In this script i am running a query in my database and fetching data which i am saving in a file using SPOOL command available in `SQLPLUS`. After saving the file i am reading the files and checking specific coluns if they have my desired result or not if not then fail.

# Qc_Queries.sql - 
In this file i have my queries saved in a variable which i am calling in my QC_Validation.sh script using SPOOL followed by the variable name.You can have your own extension here i have used *.sql you can change it accoring to your liking.
