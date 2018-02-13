requirevars 'prv_output_local_tbl' 'columns' 'input_local_tbl';

drop table if exists columnstable;
create table columnstable as
select strsplitv('%{columns}' ,'delimiter:,') as xname;

create temp table localinputtbl_1 as
select __rid as rid,__colname as colname, __val as val
from %{input_local_tbl};

var 'select_vars' from
( select group_concat('"'||xname||'"',', ') as select_vars from columnstable);

var 'var_count' from select count(*) from columnstable;

create temp table data as select %{select_vars}, 0 as C1, 0 as C2, 0 as C3  from (fromeav select * from localinputtbl_1);

select * from (output 'input.arff'
               select "@attribute relation hour-weka.filters.unsupervised.attribute.Remove-R1-2" union all
                      select "" union all select "@attribute "||column||" numeric" from (
coltypes select * from data) union all
                             select "" union all select "@data" union all select * from (csvout select * from data));

select writebinary('model.ser.prev', bin) from  %{prv_output_local_tbl};

select execprogram(null, 'java', '-jar', 'Serialization.jar', 'input.arff', '1-%{var_count}', 'model.ser.prev');
select execprogram(null, 'rm', 'input.arff');
select execprogram(null, 'rm', c2) from dirfiles(.) where c2 like "model%prev";

select bin from (unindexed select bin, execprogram(null,'rm',c2) from
(unindexed select c2, execprogram(null,'cat',c2) as bin from dirfiles(.) where c2 like "tree%ser"));
