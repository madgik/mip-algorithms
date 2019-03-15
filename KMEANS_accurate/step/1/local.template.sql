requirevars 'defaultDB' ;
attach database '%{defaultDB}' as defaultDB;

--Assign Data to Nearest Cluster
var 'a' from select create_complex_query("","(?-?_clval)*(?-?_clval)","+","",'%{columns}');
drop table if exists defaultDB.assignnearestcluster;
create table  defaultDB.assignnearestcluster as
select rid, clid, min(%{a}) as mindist
from ( select * from defaultDB.localinputtbl join (select * from defaultDB.clustercenters_local))
group by rid;

var 'a' from select create_complex_query("","sum(?) as ?_clS",",",'','%{columns}');
drop table if exists defaultDB.partialclustercenters;
create table defaultDB.partialclustercenters as 
select clid, count(clid) as clN, %{a}
from (select rid,clid,%{columns} from  (select rid, %{columns} from defaultDB.localinputtbl),
                                       (select rid as rid1, clid from assignnearestcluster)
                                 where rid=rid1)
group by clid;


select * from defaultDB.partialclustercenters;
