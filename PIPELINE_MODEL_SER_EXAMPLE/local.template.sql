requirevars 'columns' 'input_local_tbl' ;

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as xname;

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

var 'var_count' from select count(*) from columnstable;

create temp table data as select %{select_vars}, 0 as C1, 0 as C2, 0 as C3   from (fromeav select * from localinputtbl_1);

select * from (output 'input.arff'
               select "@attribute relation hour-weka.filters.unsupervised.attribute.Remove-R1-2" union all
                      select "" union all select "@attribute "||column||" numeric" from (
coltypes select * from data) union all
                             select "" union all select "@data" union all select * from (csvout select * from data));


select execprogram(null, 'java', '-jar', 'ISOUPModelTreeSerializer.jar', 'input.arff', '1-%{var_count}');

select execprogram(null, 'rm', 'input.arff');
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%pfa.action.json";
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%vis.js";

select bin from (unindexed select bin, execprogram(null,'rm',c2) from
 (unindexed select c2, execprogram(null,'cat',c2) as bin from dirfiles(.) where c2 like "mtree%ser"));
