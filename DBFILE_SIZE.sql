set pages 10000
set lines 160
set head off
set verify off 
col file_name for a57
col segment_name for a30
col tablespace_name for a25
spool '&&1._DBFILES.out'
select file_name ||','|| bytes/1024/1024 from dba_data_files where tablespace_name = '&&1' and AUTOEXTENSIBLE ='NO' order by bytes desc;
spool off
exit;
