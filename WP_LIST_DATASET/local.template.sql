requirevars 'input_local_tbl';

select execprogram(null, "/root/exareme/set-local-datasets.sh");

var 'a' from select count(distinct(__rid)) as sum1 from (select distinct rid as __rid from(postgresraw dataset));
var 'b' from select execprogram(null,'cat','/root/exareme/etc/exareme/name');
select var('a') as sum1, __val as val, var('b') as who from (select distinct val as __val from(postgresraw dataset)) group by __val;
