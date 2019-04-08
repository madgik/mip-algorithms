requirevars 'defaultDB' 'x' 'type';
attach database '%{defaultDB}' as defaultDB;

drop table if exists defaultDB.globalAnovatbl;
create table defaultDB.globalAnovatbl (no int,formula text, sst real, ssregs real, sse real);
insert into defaultDB.globalAnovatbl
select * from (select split_formula_elements('%{x}',%{type}), null ,null,  null) ;--where  formula!='intercept';

select * from defaultDB.globalAnovatbl;
