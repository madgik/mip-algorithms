requirevars 'defaultDB' 'y' 'prv_output_global_tbl' ;
attach database '%{defaultDB}' as defaultDB;

var 'prv_output_global_tbl' 'defaultDB.globalAnovatbl';

var 'formula' from select formula from %{prv_output_global_tbl} where no in ( select min(no) from %{prv_output_global_tbl} where sst is null);

drop table if exists xvariables;
create table xvariables as
select xname from (select strsplitv(regexpr("\+|\:|\*|\-",'%{formula}',"+") ,'delimiter:+') as xname) where xname!='intercept' ;

var 'xnames' from select group_concat(xname) as xname from (select distinct xname from xvariables) ;
select '%{xnames}';

var 'derivedcolumnsofmodel' from
select group_concat (modelcolnamesdummycodded) from (
select formulaparts, modelcolnamesdummycodded from (
select strsplitv(regexpr("\+",'%{formula}',"+") ,'delimiter:+') as formulaparts),
(select modelcolnames,group_concat(modelcolnamesdummycodded) as modelcolnamesdummycodded
from (select modelvariables('%{formula}','%{metadata}'))
group by modelcolnames)
where formulaparts = modelcolnames);
select '%{derivedcolumnsofmodel}';


var 'xnames2' from select create_complex_query("createderivedcolumns derivedcolumns:%{derivedcolumnsofmodel},%{y} select ","?", "," , " from defaultDB.localinputtblflat;" , '%{xnames},%{y}');
drop table if exists defaultDB.input_local_tbl_LR_Final;
create table defaultDB.input_local_tbl_LR_Final as
%{xnames2};

--C. Result (comutation of gramian and statistics):
drop table if exists defaultDB.localresult;
create table defaultDB.localresult (tablename text,attr1 text,attr2 text,val real,reccount real,colname text,S1 real,N real);

insert into defaultDB.localresult
select "gramian" as tablename, attr1,attr2, val, reccount , null, null, null
from (gramianflat select * from defaultDB.input_local_tbl_LR_Final);

insert into defaultDB.localresult
select 'statistics' as tablename, null, null, null, null,colname,  S1,  N
from (statisticsflat select * from defaultDB.input_local_tbl_LR_Final);

select * from defaultDB.localresult;



--hidden var 'defaultDB' defaultDB_ANOVA;
--attach database '%{defaultDB}' as defaultDB;
--var 'xnames'  'var_I1,var_I2,var_I3';
--var 'metadata' '{"var_I1":[0,1,2],"var_I2":[0,1,2],"var_I3":[0,1,2]}';
--var 'formula' 'intercept+var_I1+var_I2+var_I3+var_I1:var_I2+var_I1:var_I3';
--var 'derivedcolumnsofmodel' 'intercept,var_I1(1),var_I1(2),var_I2(1),var_I2(2),var_I3(1),var_I3(2),var_I1(1):var_I2(1),var_I1(1):var_I2(2),var_I1(2):var_I2(1),var_I1(2):var_I2(2),var_I1(1):var_I3(1),var_I1(1):var_I3(2),var_I1(2):var_I3(1),var_I1(2):var_I3(2)';


--
-- ------------------
-- --OLD VERSION
--
-- --Create input dataset for LR, that is input_local_tbl_LR_Final
-- drop table if exists input_local_tbl_LR;
-- create table input_local_tbl_LR as
-- select * from defaultDB.localinputtbleav
-- where colname in (select xname from xvariables) or colname = "%{y}";
--
-- -- A. Dummy code of categorical variables
-- drop table if exists T;
-- create table T as
-- select rid, colname||'('||val||')' as colname, 1 as val
-- from input_local_tbl_LR
-- where colname in (
-- select colname from (select colname, typeof(val) as t from defaultDB.localinputtbleav group by colname) where t='text');
--
-- insert into T
-- select R.rid,C.colname, 0
-- from (select distinct rid from T) R,
--      (select distinct colname from T) C
-- where not exists (select rid from T where R.rid = T.rid and C.colname = T.colname);
--
-- insert into input_local_tbl_LR
-- select * from T;
--
-- delete from input_local_tbl_LR
-- where colname in (
-- select colname from (select colname, typeof(val) as t from defaultDB.localinputtbleav group by colname) where t='text');
--
-- -- B. Model Formulae
-- drop table if exists defaultDB.input_local_tbl_LR_Final;
-- create table defaultDB.input_local_tbl_LR_Final as setschema 'rid , colname, val'
-- select modelformulaeold(rid,colname,val, "%{formula}") from input_local_tbl_LR group by rid;
--
-- var 'colnames' from select jmergeregexp(jgroup(colname)) from (select colname from defaultDB.localinputtbleav group by colname having count(distinct val)=1); --NEW
-- drop table if exists defaultDB.deletedcolumns; --NEW
-- create table defaultDB.deletedcolumns as setschema 'colname'
-- select distinct colname from defaultDB.input_local_tbl_LR_Final where regexprmatches('%{colnames}' ,colname); --NEW
--
-- delete from  defaultDB.input_local_tbl_LR_Final --NEW
-- where colname in (select * from defaultDB.deletedcolumns); --NEW
--
-- insert into defaultDB.input_local_tbl_LR_Final
-- select rid,colname,val from input_local_tbl_LR where colname = '%{y}';
-- --
-- insert into defaultDB.input_local_tbl_LR_Final
-- select distinct rid as rid,'(Intercept)' as colname, 1.0 as val from input_local_tbl_LR;
--
--
-- --C. Result:
-- drop table if exists defaultDB.localresult;
-- create table defaultDB.localresult (tablename text,attr1 text,attr2 text,val real,reccount real,colname text,S1 real,N real);
--
-- insert into defaultDB.localresult
-- select "gramian" as tablename, gramian(rid,colname, cast (val as real))  , null, null, null
-- from (select * from defaultDB.input_local_tbl_LR_Final order by rid, colname);
--
-- insert into defaultDB.localresult
-- select "statistics" as tablename, null, null, null, null,colname, FSUM(val) as S1, count(val) as N from defaultDB.input_local_tbl_LR_Final
-- group by colname;
--
-- select * from defaultDB.localresult;
