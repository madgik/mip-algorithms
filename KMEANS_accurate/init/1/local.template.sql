requirevars 'defaultDB' 'input_local_tbl' 'test_table' 'columns' 'k' 'centers';

--DELETE Lines 3 to 19
--drop table if exists mytable;
--create table mytable as 
--	select rid, key as colname, val from 
--		(select rid, jdictsplitv(cjdict) 
--		 from (file toj:1 header:t 'Normalizedtable.csv'))	 
--	where colname ='Pallidum_L_4854' or colname='Frontal_Sup_R_469';
--var 'defaultDB' 'defaultDB';
--var 'test_table' 'mytable'; 
--var 'columns' 'Pallidum_L_4854,Frontal_Sup_R_469';
--var 'centers' '{"1": {"Pallidum_L_4854":2.0,"Frontal_Sup_R_469":2.0},
--  "2": {"Pallidum_L_4854":-1.0,"Frontal_Sup_R_469":1.0},
--  "3": {"Pallidum_L_4854":1.0,"Frontal_Sup_R_469":1.0},
--  "4": {"Pallidum_L_4854":-2.0,"Frontal_Sup_R_469":-2.0},
--  "5": {"Pallidum_L_4854":0.0,"Frontal_Sup_R_469":0.0}
--  }';
--var 'k' '';
--DELETE ALL LINES ABOVE

attach database '%{defaultDB}' as defaultDB;
var 'kisempty' from select case when (select '%{k}')='' then 1 else 0 end;
var 'centersisempty' from select case when (select '%{centers}')='' then 1 else 0 end;

-- k or centers should be null. Otherwise the algorithm should stop. The algorithm should stop if Var 'error' ==1 . TODO Sofia 
var 'error' from  select case when tonumber(%{centersisempty}) + tonumber(%{kisempty}) =1 then 0 else 1 end;

drop table if exists defaultDB.columnstable;
create table defaultDB.columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as col;

--drop table if exists defaultDB.inputlocaltbl;
--create table defaultDB.inputlocaltbl as  select __rid as rid, __colname as colname, cast(__val as float) as val from %{input_local_tbl};

drop table if exists defaultDB.inputlocaltbl;
create table defaultDB.inputlocaltbl as  select rid, colname, cast(val as float) as val from %{test_table};

drop table if exists defaultDB.assignnearestcluster;
create table defaultDB.assignnearestcluster(rid  text primary key, clid, mindist);

--drop table if exists defaultDB.partialclustercenters; -- DELETE
--create table defaultDB.partialclustercenters as -- DELETE
--select  hashmodarchdep2(rid, %{k}) as clid,
select clid, clcolname,clS,clN 
from ( select (rid % tonumber('%{k}')) as clid,
			colname as clcolname,
			sum(val) as clS,
    		count(val) as clN
from ( select *
	   from defaultDB.inputlocaltbl
	  where colname in (select * from defaultDB.columnstable))
group by clid, clcolname)
where  %{centersisempty} == 1
union
select 'ok' as clid,'ok' as clcolname,'ok' as clS,'ok' as clN where %{centersisempty} == 0;


--select * from defaultDB.partialclustercenters; -- DELETE
