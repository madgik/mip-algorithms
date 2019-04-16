requirevars 'defaultDB' 'y';
attach database '%{defaultDB}' as defaultDB;

--var 'prv_output_global_tbl' 'defaultDB.globalAnovatbl';

var 'formula' from select formula from defaultDB.localAnovatbl where no in ( select min(no) from defaultDB.localAnovatbl where sst is null);
var 'metadata' from select jgroup(code,enumerations) from defaultdb.metadatatbl;


drop table if exists xvariables;
create table xvariables as
select xname from (select strsplitv(regexpr("\+|\:|\*|\-",'%{formula}',"+") ,'delimiter:+') as xname) where xname!='intercept' ;

var 'xnames' from select group_concat(xname) as xname from (select distinct xname from xvariables) ;
--select '%{xnames}';

var 'derivedcolumnsofmodel' from
select group_concat (modelcolnamesdummycodded) from (
select formulaparts, modelcolnamesdummycodded from (
select strsplitv(regexpr("\+",'%{formula}',"+") ,'delimiter:+') as formulaparts),
(select modelcolnames,group_concat(modelcolnamesdummycodded) as modelcolnamesdummycodded
from (select modelvariables('%{formula}','%{metadata}'))
group by modelcolnames)
where formulaparts = modelcolnames);
select '%{derivedcolumnsofmodel}';

var 'xnames2' from select case when '%{xnames}' <> 'None' then
create_complex_query("createderivedcolumns derivedcolumns:%{derivedcolumnsofmodel},%{y} select ","?", "," , " from defaultDB.localinputtblflat;" , '%{xnames},%{y}')
else
create_complex_query("createderivedcolumns derivedcolumns:%{derivedcolumnsofmodel},%{y} select ","?", "," , " from defaultDB.localinputtblflat;" ,'%{y}')
end;

drop table if exists defaultDB.input_local_tbl_LR_Final;
create table defaultDB.input_local_tbl_LR_Final as
%{xnames2};

--Result: (comutation of gramian and statistics):
drop table if exists defaultDB.localresult;
create table defaultDB.localresult (tablename text,attr1 text,attr2 text,val real,reccount real,colname text,S1 real,N real);

insert into defaultDB.localresult
select "gramian" as tablename, attr1,attr2, val, reccount , null, null, null
from (gramianflat select * from defaultDB.input_local_tbl_LR_Final);

insert into defaultDB.localresult
select 'statistics' as tablename, null, null, null, null,colname,  S1,  N
from (statisticsflat select * from defaultDB.input_local_tbl_LR_Final);

select * from defaultDB.localresult;
