requirevars 'defaultDB' 'prv_output_global_tbl';
attach database '%{defaultDB}' as defaultDB;

drop table if exists defaultDB.globalAnovatbl;
create table defaultDB.globalAnovatbl as select * from %{prv_output_global_tbl};

select "ok";
