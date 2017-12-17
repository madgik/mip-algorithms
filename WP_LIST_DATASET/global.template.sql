requirevars 'input_global_tbl';

drop table if exists finalresult;
create table finalresult as
select * from %{input_global_tbl};

 select jdict('result',result) from
(select jgroup('AllPatients',sum1 ,'dataset', val,'who',__local_id) as result from finalresult );



--select jdict('result',result) from(
--(select jgroup('AllPatients',sum1 , 'who',__local_id, 'other',other) as result from (select sum1,__local_id from
--(select jgroup('dataset', val) as other from finalresult)) 
--;

