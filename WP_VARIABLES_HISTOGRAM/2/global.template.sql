requirevars  'defaultDB' 'input_global_tbl';
attach database '%{defaultDB}' as defaultDB;

drop table if exists histresult;
create table histresult as
select colname0, id0, minvalue0, maxvalue0, colname1, id1,val, sum(num) as total
from  (select colname0,id0,minvalue0,maxvalue0,colname1,id1,val,num from %{input_global_tbl})
group by colname0, id0, minvalue0, maxvalue0, colname1, val
order by val,id0;

select histogramresultsviewer(colname0, id0, minvalue0, maxvalue0, colname1, id1, val,  total) from histresult;
