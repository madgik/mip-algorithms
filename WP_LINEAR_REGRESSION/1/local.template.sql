requirevars 'defaultDB' 'input_local_tbl' 'x' 'y' 'dataset';

--hidden var 'input_local_tbl' 'total_dataeav';
--hidden var 'defaultDB' defaultDB; 
--hidden var 'y' 'av45';
--hidden var 'x' 'adnicategory*apoe4+subjectage+minimentalstate+gender';
--hidden var 'dataset' 'adni';

attach database '%{defaultDB}' as defaultDB;

--create table input_local_tbl as select * from rawdb() where colname='apoe4' or colname='adnicategory' or colname='apoe4' or colname ='subjectage' or colname='minimentalstate' or colname='gender' or colname='av45';
--var 'y' from (select '%{variable}');
--var 'x' from
--( select group_concat(x,'+')
-- from ( select group_concat(x1,'+') as x from (select strsplitv('%{covariables}','delimiter:,') as x1)
 --        union
--         select group_concat(x2,'*') as x from (select strsplitv('%{groupings}','delimiter:,') as x2)));

drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

drop table if exists xvariables;
create table xvariables as
select strsplitv(regexpr("\+|\:|\*|\-",'%{x}',"+") ,'delimiter:+') as xname;


--1. Keep only the correct colnames
drop table if exists localinputtbl_1; 
create table localinputtbl_1 as
select __rid as rid,__colname as colname, tonumber(__val) as val
--select rid as rid,colname as colname, tonumber(val) as val
from %{input_local_tbl}
where colname in (select xname from xvariables) or colname = '%{y}' or colname= 'dataset' 
order by rid, colname, val;				

--2. Keep only patients of the correct dataset
drop table if exists localinputtbl_2; 
create table localinputtbl_2 as
select rid, colname, val
from localinputtbl_1
where rid in (select distinct rid  
              from localinputtbl_1 
              where colname ='dataset' and val in (select d from datasets));

--3.  Delete patients with null values 
drop table if exists localinputtbl; 
create table localinputtbl as
select rid, colname, val
from localinputtbl_2
where rid not in (select distinct rid from localinputtbl_2 
                  where val is null or val = '' or val = 'NA');

delete from localinputtbl
where colname = 'dataset';

--------------------------------------------------------------------------------------------
-- Create input dataset for LR, that is input_local_tbl_LR_Final

drop table if exists input_local_tbl_LR;
create table input_local_tbl_LR as
select * from localinputtbl
where colname in (select xname from xvariables) or colname = "%{y}";

-- A. Dummy code of categorical variables
drop table if exists T; 
create table T as
select rid, colname||'('||val||')' as colname, 1 as val
from input_local_tbl_LR
where colname in (
select colname from (select colname, typeof(val) as t from localinputtbl group by colname) where t='text');

insert into T
select R.rid,C.colname, 0
from (select distinct rid from T) R,
     (select distinct colname from T) C
where not exists (select rid from T where R.rid = T.rid and C.colname = T.colname);

insert into input_local_tbl_LR
select * from T;

delete from input_local_tbl_LR
where colname in (
select colname from (select colname, typeof(val) as t from localinputtbl group by colname) where t='text');


-- B. Model Formulae
drop table if exists defaultDB.input_local_tbl_LR_Final;
create table defaultDB.input_local_tbl_LR_Final as setschema 'rid , colname, val'
select modelFormulae(rid,colname,val, "%{x}") from input_local_tbl_LR group by rid;

insert into defaultDB.input_local_tbl_LR_Final
select rid,colname,val from input_local_tbl_LR where colname = '%{y}';  
--
insert into defaultDB.input_local_tbl_LR_Final
select distinct rid as rid,'(Intercept)' as colname, 1.0 as val from input_local_tbl_LR;

--drop table if exists T;
--drop table if exists input_local_tbl_LR;
--------------------------------------------------------------------------------------------

--drop table if exists resultlocal1;
--create table resultlocal1 as
select colname, FSUM(val) as S1, count(val) as N from defaultDB.input_local_tbl_LR_Final
group by colname;
  






