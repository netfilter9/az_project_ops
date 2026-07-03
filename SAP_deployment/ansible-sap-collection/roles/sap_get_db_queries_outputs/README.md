sap-get-db-queries-outputs
=========

This role establish connection to Hana, Sybase, Oracle, SQL and DB2 databases to execute required db queries.
To run sql queries, this role uses custom module 'mssql_query' 

Overview
------------
The configuration of sap-get-db-queries-outputs involves a number of steps (at a high level):
Based on db_type variable value it will be invoking required sub-tasks.
 
- Execute db queries
- Storing outputs in a JSON format.

Requirements
------------

Custom module 'mssql_query' python script included in this role.

Role Variables
--------------
The variables to be used within this role are all defined at group_vars or host_vars level

group_vars
-----------------------------------------
|varible|info|required?|
|---|---|---|
|sap.db.type|type of db installed|yes|
|sap.db.sid|sid of db install|yes|
|sql_db_host|required when db type is sql|yes|
|sql_db_username|required when db type is sql|yes|
|sql_db_password|required when db type is sql|yes|
|sql_db_name|required when db type is sql|yes|
|sql_db_port|required when db type is sql|yes|


Dependencies
------------

- For Oracle system make sure sql plus component should be there.


Example Playbook
----------------

    - hosts: servers
      roles:
         - sap-get-db-queries-outputs

License
-------

Accenture use only

Author Information
------------------

[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)


## References 
[Cloud Builder Developer Team design]


1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-842
