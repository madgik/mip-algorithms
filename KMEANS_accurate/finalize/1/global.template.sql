requirevars 'defaultDB' 'input_global_tbl' 'columns' 'k';
attach database '%{defaultDB}' as defaultDB;
drop table if exists defaultDB.eleni;
create table defaultDB.eleni as select * from %{input_global_tbl};

drop table if exists defaultDB.globalresult;
create table defaultDB.globalresult as 
select clid as rid,
       clcolname as colname,
       clval as val,
       clpoints as noofpoints
from defaultDB.clustercenters_global,
     ( select clid1, sum(clpoints) as clpoints
       from %{input_global_tbl}
       group by clid1 )
where clid1 = clid;
drop table if exists defaultDB.sofia;
create table defaultDB.sofia as select * from %{input_global_tbl};


drop table if exists columnstable;
create table columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as col;

--BE AWARE that there are two udf's for K_MEANS output kmeansresultsviewervis is for visual output and kmeansresultsviewerjson is for json (only the data part)
--select jdict("result",highchartresult) from (
select kmeansresultsviewer(rid,colname,val,noofpoints,noofvariables,k)
from (select * from defaultDB.globalresult order by rid),
     (select case when count(*) is null then 0 else count(*) end as noofvariables from columnstable),
(select count(distinct rid) as k from defaultDB.globalresult);