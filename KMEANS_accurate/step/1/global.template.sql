requirevars 'defaultDB' 'input_global_tbl' ;
attach database '%{defaultDB}' as defaultDB;

--var 'input_global_tbl' 'defaultDB.partialclustercenters'; --DELETE

drop table if exists defaultDB.clustercenters_global;    
create table defaultDB.clustercenters_global as select * from defaultDB.clustercentersnew_global;

drop table if exists defaultDB.clustercentersnew_global;
create table defaultDB.clustercentersnew_global as
select  clid,
        clcolname,
        sum(clS)/sum(clN) as clval
from %{input_global_tbl}
group by clid, clcolname;

select * from defaultDB.clustercentersnew_global;

--DELETE NEXT LINES
--select a.clval as Pallidum_L_4854,b.clval as Frontal_Sup_R_469
--from defaultdb.clustercentersnew_global as a,
--     defaultdb.clustercentersnew_global as b
--where a.clid =b.clid and
--	  a.clcolname ='Pallidum_L_4854' and
--	  b.clcolname='Frontal_Sup_R_469';