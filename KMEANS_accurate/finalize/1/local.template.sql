requirevars 'defaultDB' 'input_local_tbl' 'columns' 'k';
attach database '%{defaultDB}' as defaultDB;

--drop table if exists localresult; --DELETE
--create table localresult as  --DELETE

select clid as clid1, count(*) as clpoints
from defaultDB.assignnearestcluster
group by clid;

--select * from localresult; --DELETE
