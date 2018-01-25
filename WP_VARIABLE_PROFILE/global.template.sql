requirevars 'input_global_tbl' 'variable';
attach database '%{defaultDB}' as defaultDB;

-----------------
var 'HospNo'  from select count(N) as HospNo from %{input_global_tbl}; --  How many hospitals we have
var 'HospNull' from select sum(valIsNull) from %{input_global_tbl}; -- How many hospitals have null values  (empty / null all their records) (count?)
var 'HospText' from select sum(valIsText) from %{input_global_tbl}; -- 
var 'HospNumber' from select sum(valIsNumber) from %{input_global_tbl};
var 'HospCategoricalNumber'from select sum(categoricalNumber) from %{input_global_tbl};
var 'HospCategoricalText'from select sum(categoricalText) from %{input_global_tbl};

var 'categoricalNumber' from select case when (select %{HospCategoricalNumber} + %{HospNull} = %{HospNo}) and (select  %{HospNull} <> %{HospNo}) then 1 else 0 end;
var 'categoricalText' from select case when (select %{HospCategoricalText} + %{HospNull} = %{HospNo}) and (select  %{HospNull} <> %{HospNo}) then 1 else 0 end;
var 'numberV'from select case when (select %{HospNumber} + %{HospNull} = %{HospNo} ) and (select  %{HospNull} <> %{HospNo}) then 1 else 0 end;
var 'NullValues' from select case when (select %{HospNull} = %{HospNo} ) then 1 else 0 end;

-----------------
--var 'input_global_tbl' input_global_tbl;
--drop table input_global_tbl;
--create table input_global_tbl as select * from chuv_localresult;
--insert into input_global_tbl select * from epfl_localresult;
--insert into input_global_tbl select * from uoa_localresult;

drop table if exists results;
create table results as
select "SummaryStatistics" as type, '%{variable}' as code, "NA" as categories, "count" as header, case when Ntotal is null then "0" else Ntotal end as gval
from ( select colname, SUM(N) as Ntotal
       from (select * from  %{input_global_tbl} where val !='NA' ));

insert into results
select "SummaryStatistics" as type, '%{variable}' as code, "NA" as categories, "min" as header, case when ( %{categoricalNumber}= 1 or %{numberV}= 1 )  then minval else "0" end as gval
from ( select colname, min(minval) as minval
       from (select * from  %{input_global_tbl} where minval !='NA' ));

insert into results
select "SummaryStatistics" as type, '%{variable}' as code, "NA" as categories, "max" as header,  case when ( %{categoricalNumber}= 1 or %{numberV}= 1)  then maxval else "0" end  as gval
from ( select colname, max(maxval) as maxval
       from (select * from  %{input_global_tbl}  where maxval != 'NA'));

insert into results
select "SummaryStatistics" as type, '%{variable}' as code, "NA" as categories, "average" as header, case when ( %{categoricalNumber}= 1  or %{numberV}= 1 )  then FARITH('/',S1A,counts) else "0" end as gval
from ( select colname, FSUM(S2) as S2A, FSUM(S1) as S1A, SUM(N) as counts
       from (select * from %{input_global_tbl} where val !='NA'));

insert into results
select "SummaryStatistics" as type, '%{variable}' as code, "NA" as categories, "std" as header,
        case when ( %{categoricalNumber}= 1  or %{numberV}= 1 )  then SQROOT( FARITH('/', '-', '*', counts, S2A, '*', S1A, S1A, '*', counts, '-', counts, 1)) else "0" end as gval
from ( select colname, FSUM(S2) as S2A, FSUM(S1) as S1A, SUM(N) as counts
       from (select * from %{input_global_tbl} where val != 'NA'));

----------------------------
insert into results 
select "DatasetStatistics1" as type, '%{variable}' as code, "NA" as categories, val as header, Ntotal as gval
from ( select colname, val, SUM(N) as Ntotal
       from (select * from %{input_global_tbl} where %{categoricalNumber}= 1 or %{categoricalText}= 1)
       group by val);
	   
insert into results  --WHEN ALL HOSPITALS HAVE NULL VALUES
select "DatasetStatistics1" as type, '%{variable}' as code, "NA" as categories, val as header, Ntotal as gval
from ( select colname, val, SUM(Ntotal) as Ntotal
       from (select * from %{input_global_tbl} where  %{NullValues}=1)
       group by val);	   
	   
---------------------------
	   
--insert into results 
--select "DatasetStatistics2" as type, '%{variable}' as code, val as categories, partner as header, N as gval 
--from (select * from  %{input_global_tbl}
     -- where %{categoricalNumber}= 1 or %{categoricalText}= 1
--      group by partner,val);
	
	
insert into results --WHEN ALL HOSPITALS HAVE NULL VALUES
select "DatasetStatistics2" as type, '%{variable}' as code, val as categories, partner as header, Ntotal as gval 
from (select * from  %{input_global_tbl} where %{NullValues}=1 group by partner,val);	  
	  
	  
insert into results 
select "DatasetStatistics2" as type, '%{variable}' as code, val as categories, partner as header, N as gval
from (select * from (select distinct S.__local_id,S.`__local_id:1`,
S.colname,T.val,S.minval,S.maxval,S.S1,S.S2,S.N,S.partner,S.Ntotal,S.valIsNull,S.valIsNumber,S.categoricalNumber,S.categoricalText,S.valIsText 
                     from %{input_global_tbl} S,%{input_global_tbl} T) 
	  where val||N||partner in (select val||N||partner from  %{input_global_tbl}) or 
	        (val||partner not in (select val||partner from %{input_global_tbl}) and N=0))
where  %{categoricalNumber}= 1 or %{categoricalText}= 1 ;
  

select jdict('statistics', stats) as result
from ( select jgroup(
         cast(type as text),
         cast(code as text),
         cast(categories as text),
         cast(header as text),
         cast(gval as text)
       ) as stats
      from results
);

