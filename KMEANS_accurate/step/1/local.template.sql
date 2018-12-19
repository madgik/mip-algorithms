requirevars 'defaultDB' ;
attach database '%{defaultDB}' as defaultDB;

--Assign Data to Nearest Cluster
delete from defaultDB.assignnearestcluster;
insert into defaultDB.assignnearestcluster
select  rid as rid,
        clid,
        min(dist) as mindist
from ( select rid, clid, sum( (val-clval) * (val-clval) ) as dist
       from ( select rid, colname, val, clid, clval
              from ( select * from defaultDB.inputlocaltbl )
              join defaultDB.clustercenters_local
              where colname = clcolname )
       group by rid,clid )
group by rid;


--drop table if exists defaultDB.partialclustercenters;  --DELETE
--create table defaultDB.partialclustercenters as --DELETE
select clid,
       colname as clcolname,
       --avg(val) as clval
       sum(val) as clS,
       count(val) as clN
from ( select * from defaultDB.inputlocaltbl ) as h,
      ( select * from defaultDB.assignnearestcluster) as a
where  h.rid = a.rid
group by clid, colname;

--select * from defaultDB.partialclustercenters; --DELETE