requirevars 'input_local_tbl';

--%{input_local_tbl})
select * from(
(select count(distinct(__rid)) as sum1 from %{input_local_tbl}), 
(select distinct(__val) as val from %{input_local_tbl} where __colname = 'dataset'),
(select execprogram(null,'cat','/root/exareme/etc/exareme/name') as who)  
) group by val;
