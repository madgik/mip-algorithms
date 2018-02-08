requirevars 'input_local_tbl' 'columns' 'k' 'defaultDB';
attach database '%{defaultDB}' as defaultDB; 
--hidden var 'input_local_tbl' 'epfl_dataeav';
--hidden var 'columns' 'apoe4+apoe4';
--hidden var 'dataset' 'adni';
--hidden var 'k' 4;

------------------------------------------------------------------------------------------
------- Create the correct dataset 

drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as xname;

--1. Keep only the correct colnames
drop table if exists localinputtbl_1; 
create table localinputtbl_1 as
select __rid as rid,__colname as colname, tonumber(__val) as val
--select rid as rid,colname as colname, tonumber(val) as val
from %{input_local_tbl}
where colname in (select xname from columnstable) or colname= 'dataset' 
order by rid, colname, val;				

--2. Keep only patients of the correct dataset
drop table if exists localinputtbl_2; 
create table localinputtbl_2 as
select rid, colname, val
from localinputtbl_1
where rid in (select distinct rid  
              from localinputtbl_1 
              where colname ='dataset' and val in (select d from datasets));

--3.  Delete patients with null values 
drop table if exists defaultDB.inputlocaltbl; 
create table defaultDB.inputlocaltbl as
select rid, colname, val
from localinputtbl_2
where rid not in (select distinct rid from localinputtbl_2 
                  where val is null or val = '' or val = 'NA');

delete from defaultDB.inputlocaltbl
where colname = 'dataset';

var 'type' from select case when (select distinct(typeof(tonumber(val))) as val from inputlocaltbl where colname in (select * from columnstable))='integer' or  (select distinct(typeof(tonumber(val))) as val from inputlocaltbl where colname in (select * from columnstable))='real' or (select distinct(typeof(tonumber(val))) as val from inputlocaltbl where colname in (select * from columnstable))='float' then 1 else 0 end;
vartype '%{type}';

drop table if exists clustercentersnew;
create table clustercentersnew as
select  hashmodarchdep2(rid, %{k}) as clid,
	    colname as clcolname,
        avg(val) as clval
from ( select *
       from inputlocaltbl
       where colname in (select * from columnstable))
group by clid, clcolname;


drop table if exists clustercenters;
create table clustercenters as select * from clustercentersnew;
update clustercenters set clval = clval-1;


drop table if exists assignnearestcluster;
create table assignnearestcluster(rid  text primary key, clid, mindist);


-- Run Loop
execnselect 'columns' 'k' 
select filetext('kmeanslooplocal.sql')
from ( whilevt select min(diff)=0
               from (  select clold.clval = clnew.clval as diff
                       from clustercenters as clold,
                            clustercentersnew as clnew
                       where clold.clid = clnew.clid and clold.clcolname = clnew.clcolname)
 );


select clid as rid,
       clcolname as colname,
       clval as val,
       clpoints as weight
from clustercenters,
     ( select clid as clid1, count(*) as clpoints
       from assignnearestcluster
       group by clid )
where clid1 = clid;
