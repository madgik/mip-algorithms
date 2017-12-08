requirevars 'input_global_tbl' 'variable';
attach database '%{defaultDB}' as defaultDB;
--var 'categorical' from select categorical from defaultDB.variables;
--var 'valIsNumber' from select valIsNumber from defaultDB.variables; 
--var 'valIsText' from select case when (select typeof(val) from %{input_global_tbl} limit 1) ='text' then "True" else "False" end;
-----

var 'HospNo' from select count(N) as HospNo from %{input_global_tbl}; --  How many hospitals we have
var 'HospNull' from select sum(valIsNull) from %{input_global_tbl}; -- How many hospitals have null values  (empty / null all their records) (count?)
var 'HospText' from select sum(valIsText) from %{input_global_tbl}; -- 
var 'HospNumber' from select sum(valIsNumber) from %{input_global_tbl};
var 'HospCategorical'from select sum(categorical) from %{input_global_tbl};

var 'categorical' from select case when (select %{HospCategorical} + %{HospNull} = %{HospNo}) and (select  %{HospNull} <> %{HospNo}) then "True" else "False" end;
var 'number' from select case when (select %{HospNumber} + %{HospNull} = %{HospNo} ) and (select  %{HospNull} <> %{HospNo}) then "True" else "False" end;

drop table if exists finalresult;
create table finalresult as
select
  countsTotal ,
  countsWithoutNull ,
  case when ('%{categorical}'='True' or '%{number}'='True')  then FARITH('/',S1A,counts) else "0" end as averageval,
  case when ('%{categorical}'='True' or '%{number}'='True')  then minval else "0" end as minval,
  case when ('%{categorical}'='True' or '%{number}'='True')  then maxval else "0" end as maxval,
  case when ('%{categorical}'='True' or '%{number}'='True')  then SQROOT( FARITH('/', '-', '*', counts, S2A, '*', S1A, S1A, '*', counts, '-', counts, 1)) else "0" end as stdval
from ( select
          min(minval) as minval,
          max(maxval) as maxval,
		  SUM(N) as counts,
          FSUM(S2) as S2A,
          FSUM(S1) as S1A
       from %{input_global_tbl}
       where val <>'NA' 
),
(select SUM(N) as countsWithoutNull from %{input_global_tbl}),
(select SUM(Ntotal) as countsTotal from %{input_global_tbl});


select jdict('code','%{variable}', 'dataType', "SummaryStatistics", 'count',countsWithoutNull, 'min', minval,'max', maxval,'average', averageval,'std',stdval)
from finalresult;


