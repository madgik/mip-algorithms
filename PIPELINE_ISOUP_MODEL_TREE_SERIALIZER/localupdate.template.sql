requirevars 'prv_output_local_tbl' 'target_attributes' 'descriptive_attributes' 'input_local_tbl';

------- Create the correct dataset 
drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

drop table if exists targetstable;
create table targetstable as
select strsplitv('%{target_attributes}' ,'delimiter:,') as targetname;

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{target_attributes},%{descriptive_attributes}' ,'delimiter:,') as xname;

create temp table localinputtbl_1 as
select __rid as rid,__colname as colname, __val as val
from %{input_local_tbl};

var 'target_vars' from
( select group_concat('"'||targetname||'"',', ') from targetstable);

--delete from localinputtbl_1 where rid in (select distinct rid from localinputtbl_1 where colname in ("||%{target_attributes}||") and val is null);

delete from localinputtbl_1 where rid in (select distinct rid from localinputtbl_1 where colname in (%{target_vars}) and val is null);

--Check if descriptive_attributes is empty
var 'empty' from select case when (select '%{descriptive_attributes}')='' then 0 else 1 end;
emptyfield '%{empty}';
---------
--Check if target_attributes is empty
var 'empty' from select case when (select '%{target_attributes}')='' then 0 else 1 end;
emptyfield '%{empty}';
---------
--Check if dataset is epmpty
var 'empty' from select case when (select '%{dataset}')='' then 0 else 1 end;
emptyset '%{empty}';
------------------
create table columnexist as setschema 'colname' select distinct(colname) from (postgresraw);
--Check if columns exist
var 'counts' from select count(distinct(colname)) from columnexist where colname in (select xname from columnstable);
var 'result' from select count(distinct(xname)) from columnstable;
var 'valExists' from select case when(select %{counts})=%{result} then 1 else 0 end;			
vars '%{valExists}'; 
------

var 'select_vars' from
( select group_concat('"'||xname||'"',', ') as select_vars from columnstable);

var 'target_var_count' from select count(*) from (select strsplitv('%{target_attributes}' ,'delimiter:,') as xname);

create temp table data as select %{select_vars}  from (fromeav select * from localinputtbl_1 where rid in (select rid from localinputtbl_1 where colname = 'dataset' and val in (select d from datasets)));

----Check if number of patients are more than minimum records----
var 'minimumrecords' 10;
create temp table emptytable as select * from data limit 0;
var 'privacycheck' from select case when (select count(*) from data) < %{minimumrecords} then 0 else 1 end;
create temp table safeData as 
select * from data where %{privacycheck}=1
union all
select * from emptytable where %{privacycheck}=0;
------

arff_writer select  * from safeData;

select writebinary('model.ser.prev', bin) from  %{prv_output_local_tbl};

select execprogram(null, 'java', '-jar', 'ISOUPModelTreeSerializer.jar', 'input.arff', '1-%{target_var_count}', 'model.ser.prev');
select execprogram(null, 'rm', 'input.arff');
select execprogram(null, 'rm', c2) from dirfiles(.) where c2 like "model%prev";
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%pfa.action.json";
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%vis.js";

select bin from (unindexed select bin, execprogram(null,'rm',c2) from
(unindexed select c2, execprogram(null,'cat',c2) as bin from dirfiles(.) where c2 like "mtree%ser"));
