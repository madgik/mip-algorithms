requirevars 'defaultDB' 'input_local_tbl' 'x' 'y' 'dataset';
attach database '%{defaultDB}' as defaultDB;

--hidden var 'y' 'leftaccumbensarea';
--hidden var 'x' 'rs3818361_t*apoe4+gender';
--hidden var 'dataset' 'adni';

--hidden var 'groupings' '';--'DX_bl,APOE4';
--hidden var 'covariables' 'AGE,PTEDUCAT,PTGENDER';

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

drop table if exists localinputtbl1;
create table localinputtbl1 as
select __rid as rid,__colname as colname, tonumber(__val) as val
from %{input_local_tbl}
where colname in (select xname from xvariables) or colname = '%{y}' or colname ='dataset'
order by rid, colname, val;					--	Query 8

drop table if exists localinputtbl;
create table localinputtbl as
select rid, colname, val
from localinputtbl1
where rid not in (select distinct rid from localinputtbl1 where val is null or val = '' or val = 'NA')
and rid in (select distinct rid from localinputtbl1 where colname ='dataset' and val in (select d from datasets))
order by rid, colname, val;

delete from localinputtbl
where colname = 'dataset';

--------------------------------------------------------------------------------------------
-- Create input dataset for LR, that is input_local_tbl_LR_Final

drop table if exists input_local_tbl_LR;
create table input_local_tbl_LR as
select * from localinputtbl
order by rid, colname, val;
--where colname in (select xname from xvariables) or colname = "%{y}";

-- A. Dummy code of categorical variables
drop table if exists T;
create table T as
select rid, colname||'('||val||')' as colname, 1 as val
from input_local_tbl_LR
where colname in (
select colname from (select colname, typeof(val) as t from input_local_tbl_LR group by colname) where t='text');

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
create table defaultDB.input_local_tbl_LR_Final as select modelFormulae(rid,colname,val, "%{x}") from input_local_tbl_LR group by rid;
--select modelFormulae(rid,colname,val, 'rs3818361_t*apoe4+gender') from input_local_tbl_LR group by rid;

insert into defaultDB.input_local_tbl_LR_Final
select rid,colname,val from input_local_tbl_LR where colname = '%{y}';  ---Query 21 ERROR
--
insert into defaultDB.input_local_tbl_LR_Final
select distinct rid as rid,'(Intercept)' as colname, 1.0 as val from input_local_tbl_LR;

drop table if exists T;
drop table if exists input_local_tbl_LR;
--------------------------------------------------------------------------------------------


select colname, FSUM(val) as S1, count(val) as N from defaultDB.input_local_tbl_LR_Final
group by colname;


