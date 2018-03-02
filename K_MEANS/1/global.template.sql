requirevars 'input_global_tbl' 'columns' 'k' 'defaultDB';
attach database '%{defaultDB}' as defaultDB;
--var 'input_global_tbl' 'localresult';

--drop table if exists globalresult;
--create table globalresult as
select case when sum(patients)<=%{k} then 0 else 1 end as res from %{input_global_tbl};
