requirevars 'prv_output_local_tbl' 'columns';

drop table if exists columnstable;
create table columnstable as
  select strsplitv('%{columns}' ,'delimiter:,') as xname;


var 'select_vars' from
( select group_concat('"'||xname||'"',', ') as select_vars from columnstable);

var 'var_count' from select count(*) from columnstable;

create temp table data as select %{select_vars}, 0 as C1, 0 as C2, 0 as C3;

select * from (output 'input.arff'
               select "@attribute relation hour-weka.filters.unsupervised.attribute.Remove-R1-2" union all
                      select "" union all select "@attribute "||column||" numeric" from (
coltypes select * from data) union all
                             select "" union all select "@data" );

select writebinary('model.ser.prev', bin) from  %{prv_output_local_tbl};

select execprogram(null, 'java', '-jar', 'ISOUPModelTreeSerializer.jar', 'input.arff', '1-%{var_count}', 'model.ser.prev');
select execprogram(null, 'rm', 'input.arff');
select execprogram(null, 'rm', c2) from dirfiles(.) where c2 like "model%prev";
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%pfa.action.json";
select execprogram(null,'rm',c2) from dirfiles(.) where c2 like "mtree%ser";

var 'js_filename' from select c2 from dirfiles(.) where c2 like "mtree%vis.js";

create temp table res_js as select group_concat(C1, " ") as res from (file '%{js_filename}');
select execprogram(null, 'rm', '%{js_filename}');

select jdict("vis_js", res) from res_js;
