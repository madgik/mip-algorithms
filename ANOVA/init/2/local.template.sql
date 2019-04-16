requirevars 'defaultDB' 'prv_output_global_tbl';
attach database '%{defaultDB}' as defaultDB;

drop table if exists defaultDB.localAnovatbl;
create table defaultDB.localAnovatbl as select * from %{prv_output_global_tbl};

select "ok";
