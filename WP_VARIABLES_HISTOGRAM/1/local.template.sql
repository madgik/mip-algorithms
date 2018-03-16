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
from %{input_local_tbl};		

var 'valExists' from select case when (select exists (select colname from localinputtbl_1 where colname='%{column1}'))=0 then 0 else 1 end;
vars '%{valExists}'; --0 false 1 true

var 'valExists' from select case when (select exists (select colname from localinputtbl_1 where colname='%{column2}'))=0 then 0 else 1 end;
vars '%{valExists}'; --0 false 1 true


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

----Check if number of patients are more than minimum records----
var 'minimumrecords' 10;
create table emptytable(rid  text primary key, colname, val);
var 'privacycheck' from select case when (select count(distinct(rid)) from inputlocaltbl1) < %{minimumrecords} then 0 else 1 end;
drop table if exists defaultDB.inputlocaltbl;
create table defaultDB.inputlocaltbl as setschema 'rid , colname, val' 
select * from inputlocaltbl1 where %{privacycheck}=1
union 
select * from emptytable where %{privacycheck}=0;
-----------------------------------------------------------------

select colname,
       min(val) as minvalue,
       max(val) as maxvalue,
       FSUM(val) as S1,
       FSUM(FARITH('*', val, val)) as S2,
       count(val) as N
from defaultDB.inputlocaltbl
where colname = '%{column1}';



