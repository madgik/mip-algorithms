requirevars 'input_local_tbl' 'columns' 'k' 'defaultDB';
attach database '%{defaultDB}' as defaultDB; 
--hidden var 'input_local_tbl' 'epfl_dataeav';
--hidden var 'columns' 'apoe4+apoe4';
--hidden var 'dataset' 'adni';
--hidden var 'k' 4;

------------------------------------------------------------------------------------------
------- Create the correct dataset 

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
--select rid as rid,colname as colname, tonumber(val) as val
from %{input_local_tbl};
--where colname in (select xname from columnstable) or colname= 'dataset' 
--order by rid, colname, val;				


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
where colname = 'dataset';

--3.  Delete patients with null values 
drop table if exists defaultDB.inputlocaltbl; 
create table defaultDB.inputlocaltbl as
select rid, colname, val
from localinputtbl_2
where rid not in (select distinct rid from localinputtbl_2 
                  where val is null or val = '' or val = 'NA')
order by rid, colname, val;

--Need to check if Inputlocaltbl is epmpty...If it is, then 'type' is 0 By Sof
var 'type' from select case when (select distinct(typeof(tonumber(val))) as val from defaultDB.inputlocaltbl where colname in (select * from columnstable))='integer' or  (select distinct(typeof(tonumber(val))) as val from defaultDB.inputlocaltbl where colname in (select * from columnstable))='real' or (select distinct(typeof(tonumber(val))) as val from defaultDB.inputlocaltbl where colname in (select * from columnstable))='float' then 1 else 0 end;
var 'empty' from select count(*) from defaultDB.inputlocaltbl;
var 'checkEpmpty' from select case when (select  %{empty})= 0 then 1 else 0 end;
var 'final' from select case when  (%{type}=0 and  %{checkEpmpty}=1) or (%{type}=1 and %{checkEpmpty}=0) then 1 else 0 end;
vartype '%{final}';
--

select count(distinct rid) as patients from defaultDB.inputlocaltbl;


