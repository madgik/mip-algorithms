requirevars 'defaultDB' ;
attach database '%{defaultDB}' as defaultDB;

update iterationsDB.iterations_condition_check_result_tbl set iterations_condition_check_result = (
	select (null in (select sst from defaultDB.globalAnovatbl))
);

select "ok";
