requirevars 'input_local_tbl';

select execprogram(null, "/root/exareme/set-local-datasets.sh");

var 'a' from select count(distinct(__rid)) as sum1 from (select distinct __rid from %{input_local_tbl});

var 'b' from select execprogram(null,'cat','/root/exareme/etc/exareme/name');
select var('a') as sum1, __val as val, var('b') as who from (select distinct __val from %{input_local_tbl} where __colname = 'dataset') group by __val;

