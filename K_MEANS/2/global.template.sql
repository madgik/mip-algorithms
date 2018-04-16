requirevars 'input_global_tbl' 'columns' 'k' 'defaultDB';
attach database '%{defaultDB}' as defaultDB; 

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as col;

drop table if exists eavdatatable;
create table eavdatatable as
select (__local_id) * %{k} + rid as rid, colname, val, weight
from %{input_global_tbl};

drop table if exists globaltableinput;
create table globaltableinput as
select * from eavdatatable;

drop table if exists clustercentersnew;
create table clustercentersnew as
select  hashmodarchdep(rid, %{k}) as clid,
	    colname as clcolname,
        avg(val) as clval
from ( select * from eavdatatable where colname in (select * from columnstable) )
group by clid, clcolname;


drop table if exists clustercenters;
create table clustercenters as select * from clustercentersnew;
update clustercenters set clval = clval-1;

drop table if exists assignnearestcluster;
create table assignnearestcluster(rid integer primary key, clid, mindist);

-- Run Loop
execnselect 'path:/root/mip-algorithms/K_MEANS' 'columns' 'k'
select filetext('/root/mip-algorithms/K_MEANS/2/kmeansloopglobal.sql')
 from (whilevt select case when mydiff is null then 0 else mydiff end
      from (   select min(diff)=0 as mydiff
      from (  select clold.clval = clnew.clval as diff
        from clustercenters as clold,
          clustercentersnew as clnew
        where clold.clid = clnew.clid and clold.clcolname = clnew.clcolname))
);

drop table if exists defaultDB.globalresult;
create table defaultDB.globalresult as 
select clid as clid,
       clcolname as colname,
       clval as val,
       weight as noofpoints
from clustercenters,
    ( select rid1, clid1, sum(weight) as weight
      from ( select distinct e.rid as rid1, a.clid as clid1, e.weight as weight
             from eavdatatable as e,
                  assignnearestcluster as a
             where a.rid = e.rid
           )
      group by clid1
    )
where clid1 = clid;

--BE AWARE that there are two udf's for K_MEANS output kmeansresultsviewervis is for visual output and kmeansresultsviewerjson is for json (only the data part)
--select jdict("result",highchartresult) from (
select kmeansresultsviewerjson(clid,colname,val,noofpoints,noofvariables,k) 
from (select * from defaultDB.globalresult order by clid),
     (select case when count(*) is null then 0 else count(*) end as noofvariables from columnstable),
     (select count(distinct clid) as k from defaultDB.globalresult);
