requirevars 'defaultDB' 'input_local_tbl' 'column1' 'column2' 'nobuckets' 'dataset';
attach database '%{defaultDB}' as defaultDB;

------- Create the correct dataset 
drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

--1. Keep only the correct colnames
drop table if exists localinputtbl_1; 
create table localinputtbl_1 as
select __rid as rid,__colname as colname, tonumber(__val) as val
from %{input_local_tbl}	;	

---- Check If variables exist in the dataset 
--var 'valExists1' from select max(check1,check2) from
--(select case when (select '%{column1}')='' then 0 else 1 end as check1),
--(select case when (select exists (select colname from localinputtbl_1 where colname='%{column1}'))=0 then 0 else 1 end as check2);
--vars '%{valExists1}'; --0 false 1 true

--var 'valExists2' from select max(check1,check2) from
--(select case when (select '%{column2}')='' then 1 else 0 end as check1),
--(select case when (select exists (select colname from localinputtbl_1 where colname='%{column2}'))=0 then 0 else 1 end as check2);
--vars '%{valExists2}'; --0 false 1 true

--Check if column1 is empty
var 'empty' from select case when (select '%{column1}')='' then 0 else 1 end;
emptyfield '%{empty}';
------------------
--Check if nobuckets is empty
var 'empty' from select case when (select '%{nobuckets}')='' then 0 else 1 end;
emptyfield '%{empty}';
------------------
--Check if dataset is empty
var 'empty' from select case when (select '%{dataset}')='' then 0 else 1 end;
emptyset '%{empty}';
------------------
--Check if nobuckets is integer
var 'checktype' from select case when (select typeof(tonumber('%{nobuckets}'))) = 'integer' then 1 else 0 end;
vartypebucket '%{checktype}';
-----------------
create table columnexist as setschema 'colname' select distinct(colname) from (postgresraw);
--Check if column1 exist in the dataset
var 'valExists' from select case when (select exists (select colname from columnexist where colname='%{column1}'))=0 then 0 else 1 end;
vars '%{valExists}';
--Check if column2 exist in the dataset
var 'valExists2' from select max(check1,check2) from
(select case when (select '%{column2}')='' then 1 else 0 end as check1),
(select case when (select exists (select colname from columnexist where colname='%{column2}'))=0 then 0 else 1 end as check2);
vars '%{valExists2}'; 
----------------------

--2. Keep only patients of the correct dataset
drop table if exists localinputtbl_2; 
create table localinputtbl_2 as
select rid, colname, val
from localinputtbl_1
where rid in (select distinct rid  
              from localinputtbl_1 
              where colname ='dataset' and val in (select d from datasets));

--3.  Delete patients with null values 
drop table if exists inputlocaltbl1; 
create table inputlocaltbl1 as
select rid, colname, val
from localinputtbl_2
where rid not in (select distinct rid from localinputtbl_2 
                  where val is null or val = '' or val = 'NA');

delete from inputlocaltbl1
where colname = 'dataset';

drop table if exists defaultDB.inputlocaltbl;
create table defaultDB.inputlocaltbl as select * from inputlocaltbl1;

----Check types of columns ----
var 'datasestisempty' from select case when count(*)=0 then 1 else 0 end from defaultDB.inputlocaltbl;
var 'iscorrecttypecolumn1' from
select booltypeval from
( select case when typeval = 'integer' or  typeval = 'float' or  typeval = 'real' then 1 else 0 end as booltypeval
  from (select distinct(typeof(tonumber(val))) as typeval from defaultDB.inputlocaltbl where colname = '%{column1}')
  where %{datasestisempty} == 0)
union 
select 1 as booltypeval where  %{datasestisempty} == 1;

var 'column2isempty' from select (select '%{column2}')='';
var 'iscorrecttypecolumn2' from 
select booltypeval
from ( select case when typeval = 'text'  then 1 else 0 end as booltypeval
		from (select distinct(typeof(tonumber(val))) as typeval from defaultDB.inputlocaltbl where colname = '%{column2}' )
		where  %{column2isempty} = 0 and %{datasestisempty}= 0)
union 
select 1 as booltypeval where %{column2isempty} =1 or %{datasestisempty}= 1;

var 'checkcolumnstypes' from select case when( %{iscorrecttypecolumn1}=0 or %{iscorrecttypecolumn2}=0 ) = 1 then 0 else 1 end;
vartypeshistogram '%{checkcolumnstypes}';

-----------------------------------------------------------------
drop table if exists defaultDB.localResult;
create table defaultDB.localResult as
select  '%{column1}' as colname,
       min(val) as minvalue,
       max(val) as maxvalue,
       FSUM(val) as S1,
       FSUM(FARITH('*', val, val)) as S2,
       count(val) as N,
	   count(distinct rid) as patients --NEW 
from defaultDB.inputlocaltbl
where colname = '%{column1}';

select * from defaultDB.localResult;
