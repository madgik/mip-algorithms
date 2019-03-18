requirevars 'defaultDB' 'input_global_tbl' 'columns' 'outputformat';
attach database '%{defaultDB}' as defaultDB;

var 'input_global_tbl' 'localresult';

var 'a' from select create_complex_query("","?_clval as ?",",","",'%{columns}');
drop table if exists defaultDB.globalresult;
create table defaultDB.globalresult as
select clid , %{a}, clpoints as noofpoints
from defaultDB.clustercenters_global,
     ( select clid1, sum(clpoints) as clpoints from %{input_global_tbl} group by clid1 )
where clid1 = clid;

setschema 'result'
select * from (highchartbubble select %{columns}, noofpoints  from lala)
where '%{outputformat}'= 'highchart_bubble'
union
setschema 'result'
select * from (highchartscatter3d select %{columns}, noofpoints from lala)
where '%{outputformat}'= 'highchart_scatter3d'
union
setschema 'result'
select * from (totabulardataresourceformat select clid as `cluster id`, %{columns}, noofpoints as `number of points`
from lala) where '%{outputformat}'= 'pfa';
