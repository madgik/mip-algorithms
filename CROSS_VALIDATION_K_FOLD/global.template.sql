requirevars 'defaultDB' 'input_global_tbl' 'DBIdentifier';

--var 'input_global_tbl' 'defaultDB.local_variablesdatatype_Existing';

attach database '%{defaultDB}' as defaultDB;

drop table if exists defaultDB.global_variablesdatatype_Existing;
create table defaultDB.global_variablesdatatype_Existing as 
select * from %{input_global_tbl};

drop table if exists defaultDB.global_confusionmatrix;
create table defaultDB.global_confusionmatrix (
iterationnumber int,
typecolname text, -- confusion table, statistics, 
actualclass text, 
predictedclass text,
typestats text, --overall, by class , average
statscolname text,
val float);

select jdict('DBIdentifier', '%{DBIdentifier}') as results;