requirevars 'input_local_tbl' 'columns' 'k' 'defaultDB';
attach database '%{defaultDB}' as defaultDB; 

drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as xname;

--1. Keep only the correct colnames
drop table if exists localinputtbl_1; 
create table localinputtbl_1 as
select __rid as rid,__colname as colname, tonumber(__val) as val
from %{input_local_tbl};

--Check If variableS exist
var 'counts' from select count(xname) from columnstable where xname in (select distinct(colname) from localinputtbl_1);		-->>By Sof
var 'result' from select count(xname) from columnstable;						
var 'valExists' from select case when(select %{counts})=%{result} then 1 else 0 end;			
vars '%{valExists}'; 	
--
--2. Keep only patients of the correct dataset
drop table if exists localinputtbl_2; 
create table localinputtbl_2 as
select rid, colname, val
from localinputtbl_1
where rid in (select distinct rid  
              from localinputtbl_1 
              where colname ='dataset' and val in (select d from datasets));

delete from localinputtbl_2
where colname = 'dataset';			--14 query

--3.  Delete patients with null values 
drop table if exists inputlocaltbl1; 
create table inputlocaltbl1 as
select rid, colname, val
from localinputtbl_2
where rid not in (select distinct rid from localinputtbl_2 
                  where val is null or val = '' or val = 'NA')
order by rid, colname, val;

--Real,Float,Integer only->Need to check if Inputlocaltbl is epmpty...If it is, then 'type' is 0 By Sof
var 'type' from select case when (select distinct(typeof(tonumber(val))) as val from inputlocaltbl1 where colname in (select * from columnstable))='integer' or  (select distinct(typeof(tonumber(val))) as val from inputlocaltbl1 where colname in (select * from columnstable))='real' or (select distinct(typeof(tonumber(val))) as val from inputlocaltbl1 where colname in (select * from columnstable))='float' then 1 else 0 end;
var 'empty' from select count(*) from inputlocaltbl1;
var 'checkEpmpty' from select case when (select  %{empty})= 0 then 1 else 0 end;
var 'final' from select case when  (%{type}=0 and  %{checkEpmpty}=1) or (%{type}=1 and %{checkEpmpty}=0) then 1 else 0 end;
vartype '%{final}';
---------------------------------------------------------------------------------------------------------

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


select count(distinct rid) as patients from defaultDB.inputlocaltbl;


