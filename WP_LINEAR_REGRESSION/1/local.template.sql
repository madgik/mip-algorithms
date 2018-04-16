requirevars 'defaultDB' 'input_local_tbl' 'x' 'y' 'dataset';
attach database '%{defaultDB}' as defaultDB;

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
from %{input_local_tbl};

--Check if x is empty
var 'empty' from select case when (select '%{x}')='' then 0 else 1 end;
emptyfield '%{empty}';
------------------
--Check if y is epmpty
var 'empty' from select case when (select '%{y}')='' then 0 else 1 end;
emptyfield '%{empty}';
------------------

create table columnexist as setschema 'colname' select distinct(colname) from (postgresraw);
--Check if x exist
var 'counts' from select count(distinct(colname)) from columnexist where colname in (select xname from xvariables);
var 'result' from select count(xname) from xvariables;
var 'valExists' from select case when(select %{counts})=%{result} then 1 else 0 end;			
vars '%{valExists}';
--Check if y exist
var 'valExists' from select case when (select exists (select colname from columnexist where colname='%{y}'))=0 then 0 else 1 end;
vars '%{valExists}';
----------

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
drop table if exists localinputtbl; 
create table localinputtbl as
select rid, colname, val
from localinputtbl_2
where rid not in (select distinct rid from localinputtbl_2 
                  where val is null or val = '' or val = 'NA')
order by rid, colname, val;

----Check if number of patients are more than minimum records----
var 'minimumrecords' 10;
create table emptytable(rid  text primary key, colname, val);
var 'privacycheck' from select case when (select count(distinct(rid)) from localinputtbl) < %{minimumrecords} then 0 else 1 end;
create table localinputtbl2 as setschema 'rid , colname, val' 
select * from localinputtbl where %{privacycheck}=1
union 
select * from emptytable where %{privacycheck}=0;
drop table if exists localinputtbl;
alter table localinputtbl2 rename to localinputtbl;
-----------------------------------------------------------------

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

select colname, FSUM(val) as S1, count(val) as N from defaultDB.input_local_tbl_LR_Final
group by colname;
