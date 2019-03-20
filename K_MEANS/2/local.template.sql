requirevars  'prv_output_global_tbl' 'columns' 'k' 'defaultDB';

--var 'privacyfilter' 1;  --For algorithm testing

attach database '%{defaultDB}' as defaultDB;

var 'privacyfilter' from select res from %{prv_output_global_tbl};

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as xname;

var 'k1' from select 2*cast(%{k} as int);

drop table if exists clustercentersnew;
create table clustercentersnew as
select  clid,
	      colname as clcolname,
        avg(val) as clval
from ( select rid,colname,val,rid, clid
       from defaultDB.inputlocaltbl,
			 (select rid as rid1,idofset as clid from (sklearnkfold splits:%{k1} select distinct rid from defaultDB.inputlocaltbl))
       where %{privacyfilter}= 1  and rid =rid1)
group by clid, clcolname;


drop table if exists clustercenters;
create table clustercenters as select * from clustercentersnew;
update clustercenters set clval = clval-1;

drop table if exists assignnearestcluster;
create table assignnearestcluster(rid  text primary key, clid, mindist);

-- Run Loop
execnselect 'columns' 'k'
select filetext('/home/eleni/Desktop/Link to mip-algorithms/K_MEANS/2/kmeanslooplocal.sql')
from ( whilevt select min(diff)=0
               from (  select clold.clval = clnew.clval as diff
                       from clustercenters as clold,
                            clustercentersnew as clnew
                       where clold.clid = clnew.clid and clold.clcolname = clnew.clcolname)
 );

drop table if exists localresult; --For testing
create table localresult as --For testing
select clid as rid,
       clcolname as colname,
       clval as val,
       clpoints as weight
from clustercenters,
     ( select clid as clid1, count(*) as clpoints
       from assignnearestcluster
       group by clid )
where clid1 = clid;

select * from localresult; --For testing
