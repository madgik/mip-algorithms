requirevars 'target_attributes' 'descriptive_attributes' 'input_local_tbl' ;

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{target_attributes},%{descriptive_attributes}' ,'delimiter:,') as xname;

create temp table localinputtbl_1 as
select __rid as rid,__colname as colname, __val as val
from %{input_local_tbl};

--Check If variableS exist
var 'counts' from select count(xname) from columnstable where xname in (select distinct(colname) from localinputtbl_1);		-->>By Sof
var 'result' from select count(xname) from columnstable;						
var 'valExists' from select case when(select %{counts})=%{result} then 1 else 0 end;			
vars '%{valExists}'; 	
--

var 'select_vars' from
( select group_concat('"'||xname||'"',', ') as select_vars from columnstable);

var 'target_var_count' from select count(*) from (select strsplitv('%{target_attributes}' ,'delimiter:,') as xname);

create temp table data as select %{select_vars}  from (fromeav select * from localinputtbl_1);

----Check if number of patients are more than minimum records----
var 'minimumrecords' 10;
create temp table emptytable as select * from data limit 0;
var 'privacycheck' from select case when (select count(*) from data) < %{minimumrecords} then 0 else 1 end;
create temp table safeData as 
select * from data where %{privacycheck}=1
union all
select * from emptytable where %{privacycheck}=0;
------

select * from (output 'input.arff'
               select "@attribute relation hour-weka.filters.unsupervised.attribute.Remove-R1-2" union all
                      select "" union all select "@attribute "||column||" numeric" from (
coltypes select * from safeData) union all
                             select "" union all select "@data" union all select * from (csvout select * from safeData));


select execprogram(null, 'java', '-jar', 'ISOUPModelTreeSerializer.jar', 'input.arff', '1-%{target_var_count}');

select execprogram(null, 'rm', 'input.arff');
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%pfa.action.json";
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%vis.js";

select bin from (unindexed select bin, execprogram(null,'rm',c2) from
 (unindexed select c2, execprogram(null,'cat',c2) as bin from dirfiles(.) where c2 like "mtree%ser"));
