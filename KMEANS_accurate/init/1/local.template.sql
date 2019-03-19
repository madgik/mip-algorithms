requirevars 'defaultDB' 'input_local_tbl' 'dataset' 'columns' 'k' 'centers' ;

--Input for testing the algorithm
--drop table if exists rawtable;create table rawtable as select * from (file header:t 'chuv_flattable.csv');
-- var 'defaultDB' 'defaultDB';
-- var 'input_local_tbl' 'rawtable';
-- var 'columns' 'lefthippocampus,righthippocampus';
-- var 'centers' '{"1": {"Pallidum_L_4854":2.0,"Frontal_Sup_R_469":2.0},
--  "2": {"Pallidum_L_4854":-1.0,"Frontal_Sup_R_469":-1.0},
--  "3": {"Pallidum_L_4854":1.0,"Frontal_Sup_R_469":1.0},
--  "4": {"Pallidum_L_4854":-2.0,"Frontal_Sup_R_469":-2.0},
--  "5": {"Pallidum_L_4854":0.0,"Frontal_Sup_R_469":0.0}
--  }';
--var 'k' '5';
-- var 'centers' '{}';
-- var 'dataset' 'adni';
--var 'outputformat' 'pfa';
-----------------------------------------------------------------------------------------------------------------------------------
--Error Handling --TODO!!!!!!!!!!!!!!!!!

--var 'kisempty' from select case when (select '%{k}')='' then 1 else 0 end;
-- k or centers should be null. Otherwise the algorithm should stop. The algorithm should stop if Var 'error' ==1 . TODO Sofia
--var 'error' from  select case when tonumber(%{centersisempty}) + tonumber(%{kisempty}) =1 then 0 else 1 end;


-----------------------------------------------------------------------------------------------------------------------------------

attach database '%{defaultDB}' as defaultDB;


drop table if exists mytable;
create table mytable as select %{columns}, dataset from %{input_local_tbl};

var 'centersisempty' from select case when (select '%{centers}')='{}' then 1 else 0 end;
var 'a' from select create_complex_query("","tonumber(?) as ?", "," , "" , '%{columns}');
drop table if exists defaultDB.localinputtbl;
create table defaultDB.localinputtbl as
select cast(rowid as text) as rid, %{a} from mytable
where dataset in (select strsplitv('%{dataset}','delimiter:,'));

--3.  Delete patients with null values (val is null or val = '' or val = 'NA')
var 'a' from select create_complex_query("","? is null or ?='NA' or ?=''", "or" , "" , '%{columns}');
delete from defaultDB.localinputtbl where %{a};

drop table if exists defaultDB.assignnearestcluster;
create table defaultDB.assignnearestcluster(rid  text primary key, clid, mindist);

var 'schema' from select create_complex_query("clid, clN,","?_clS",",","",'%{columns}');
var 'a' from select create_complex_query("", "sum(?) as ?_clS" , "," , '' ,'%{columns}');
var 'b' from select create_complex_query("'ok','ok'," , "'?'", ",","",'%{columns}');

drop table if exists defaultDB.partialclustercenters;
create table defaultDB.partialclustercenters as
setschema '%{schema}'
select * from (select * from (select rid, count(*) as clN, %{a}  from (
select rid, clid, %{columns} from defaultDB.localinputtbl,
(select rid as rid1,idofset as clid from (sklearnkfold splits:%{k} select distinct rid from defaultDB.localinputtbl))
where rid1 =rid)
group by clid))
where %{centersisempty} == 1
union
setschema '%{schema}'
select %{b} where %{centersisempty} == 0;

select * from defaultDB.partialclustercenters;
