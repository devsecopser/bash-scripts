set pages 10000
set lines 160
set head off
col file_name for a57
col segment_name for a30
col tablespace_name for a25

spool TBS_SIZE.out

select s.name||','||d.tbs_size 
from 	
	(select nvl(b.tablespace_name,nvl(a.tablespace_name,'UNKOWN')) name,
	 kbytes_alloc kbytes,kbytes_alloc-nvl(kbytes_free,0) used,nvl(kbytes_free,0) free,
	 ((kbytes_alloc-nvl(kbytes_free,0))/kbytes_alloc)*100 pct_used,nvl(largest,0) largest
	from 
	 	(select sum(bytes)/1024 Kbytes_free,max(bytes)/1024 largest,tablespace_name from sys.dba_free_space
		group by tablespace_name) a,
		(select sum(bytes)/1024 Kbytes_alloc,tablespace_name from sys.dba_data_files group by tablespace_name)b
	where a.tablespace_name (+) = b.tablespace_name
	--order by 1
	)s , 
	(select tb.tablespace_name tbs_name,sum(tb.bytes/1024/1024) tbs_size
	from dba_data_files tb group by tb.tablespace_name) d
where s.pct_used > 90
and s.name=d.tbs_name
order by d.tbs_size ,s.pct_used;

spool off
exit
