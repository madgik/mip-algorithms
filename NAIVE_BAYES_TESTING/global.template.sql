requirevars 'input_global_tbl' 'defaultDB' 'iterationnumber';
attach database '%{defaultDB}' as defaultDB;

--var 'input_global_tbl' ' defaultDB.local_confusionmatrix';

drop table if exists defaultDB.global_oneconfusionmatrix;
create table defaultDB.global_oneconfusionmatrix as 
select  iterationnumber, actualclass, predictedclass, sum(val) as val
from %{input_global_tbl}
group by actualclass,predictedclass;

insert into defaultDB.global_confusionmatrix  
select  iterationnumber, "confusion table", actualclass, predictedclass, null,null, val from defaultDB.global_oneconfusionmatrix;

--insert into defaultDB.global_confusionmatrix  
--select %{iterationnumber}, "statistics", null,null,typestats,statscolname, statsval  
--from (rconfusionmatrixtable select predictedclass,actualclass,val,noclasses                              
--                            from defaultDB.global_oneconfusionmatrix,                                  
--							(select count(distinct predictedclass) as noclasses from defaultDB.global_oneconfusionmatrix) order by predictedclass);

--select * from defaultDB.global_oneconfusionmatrix;

select tabletojson(iterationnumber,actualclass,predictedclass,val, "iterationnumber,actualclass,predictedclass,val")  as componentresult
from defaultdb.global_oneconfusionmatrix;