requirevars 'defaultDB' 'input_global_tbl' 'centers' ;
attach database '%{defaultDB}' as defaultDB;

--var 'input_global_tbl' 'defaultDB.partialclustercenters'; --DELETE

var 'centersisempty' from select case when (select '%{centers}')='{}' then 1 else 0 end;

var 'a' from select create_complex_query("","sum(?_clS)/sum(clN) as ?_clval",",","",'%{columns}');
var 'b' from select create_complex_query("clid,","?_clval",",","",'%{columns}');
drop table if exists defaultDB.clustercentersnew_global;
create table defaultDB.clustercentersnew_global as
setschema '%{b}'
select * from (select clid, %{a} from %{input_global_tbl}  group by clid)
where %{centersisempty} = 1
union
setschema '%{b}'
select * from (
select key as clid, jdictsplit(val)  from ( setschema 'key, val' select jdictsplitv('%{centers}')))
where  %{centersisempty} = 0 ;

drop table if exists defaultDB.clustercenters_global;
create table defaultDB.clustercenters_global as select * from defaultDB.clustercentersnew_global;

select * from defaultDB.clustercentersnew_global;
