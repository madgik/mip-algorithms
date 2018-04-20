requirevars 'defaultDB' 'input_local_tbl' 'variable' 'dataset' ;
attach database '%{defaultDB}' as defaultDB;

drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

create temp table tempinputlocaltbl1 as 
select __rid as rid, __colname as colname, tonumber(__val) as val
from %{input_local_tbl};

--Check if colname is epmpty
var 'empty' from select case when (select '%{variable}')='' then 0 else 1 end;
emptyfield '%{empty}';
------------------------------------
--Check if dataset is epmpty
var 'empty' from select case when (select '%{dataset}')='' then 0 else 1 end;
emptyset '%{empty}';
------------------
create table columnexist as setschema 'colname' select distinct(colname) from (postgresraw);
var 'valExists' from select case when (select exists (select colname from columnexist where colname='%{variable}'))=0 then 0 else 1 end;
vars '%{valExists}';
-----------------------------------------------------		  

drop table if exists tempinputlocaltbl;
create table tempinputlocaltbl as 
select * from tempinputlocaltbl1
         where rid in (select rid from tempinputlocaltbl1 where colname = 'dataset' and val in (select d from datasets));
		
var 'totalcount' from select count(rid) from tempinputlocaltbl;

drop table if exists inputlocaltbl; 
create table inputlocaltbl as
select * from tempinputlocaltbl 
where val <> 'NA'     
 	and val is not null      
	and val <> ""
	and val not in (select d from datasets)
order by rid, colname,val;

----Check if number of patients are more than minimum records----
var 'minimumrecords' 10;
create table emptytable(rid  text primary key, colname, val);
var 'privacycheck' from select case when (select count(distinct(rid)) from inputlocaltbl) < %{minimumrecords} then 0 else 1 end;
create table inputlocaltbl2 as setschema 'rid , colname, val' 
select * from inputlocaltbl where %{privacycheck}=1
union 
select * from emptytable where %{privacycheck}=0;
drop table if exists inputlocaltbl;
alter table inputlocaltbl2 rename to inputlocaltbl;
-----------------------------------------------------------------

var 'valIsNull' from select case when (select count(distinct val) from inputlocaltbl)= 0 then 1 else 0 end;
var 'valIsText' from select case when (select typeof(val) from inputlocaltbl limit 1) ='text' and %{valIsNull}= 0 then 1 else 0 end;
var 'valIsNumber' from select case when (select count(distinct val) from inputlocaltbl)>= 20 and %{valIsNull}= 0 then 1 else 0 end;
var 'categorical' from select case when (select count(distinct val) from inputlocaltbl)< 20 and (select count(distinct val) from inputlocaltbl)> 0 and %{valIsNull}=0 and %{valIsText}=0 then 1 else 0 end;

--1. case when  val is a categorical number
select * from (
select *
from ( select colname,
              val,
              min(val) as minval,
              max(val) as maxval,
              FSUM(val) as S1,
              FSUM(FARITH('*', val, val)) as S2,
              count(val) as N,
			  %{totalcount} as Ntotal,
		      %{valIsNull} as valIsNull, 
			  %{valIsNumber} as valIsNumber, 
			  %{categorical} as categorical, 
			  %{valIsText} as valIsText
       from ( select * from inputlocaltbl where %{categorical}= 1)
       where val <> 'NA' and val is not null and val <> "" 
) where %{categorical}= 1

union all
--2. case when val is a number but not categorical
select *
from ( select colname,
              val,
              min(val) as minval,
              max(val) as maxval,
              FSUM(val) as S1,
              FSUM(FARITH('*', val, val)) as S2,
              count(val) as N,
			  %{totalcount} as Ntotal,
		      %{valIsNull} as valIsNull, 
			  %{valIsNumber} as valIsNumber, 
			  %{categorical} as categorical, 
			  %{valIsText} as valIsText
       from ( select * from inputlocaltbl where %{valIsNumber} = 1)
       where val <> 'NA' and val is not null and val <> ""
)where %{valIsNumber} = 1

union all
--3. case when val is text
select *
from ( select colname,
              val,
              "NA" as minval,
              "NA" as maxval,
              1 as S1,
              1 as S2,
              count(val) as N,
              %{totalcount} as Ntotal,
		      %{valIsNull} as valIsNull, 
			  %{valIsNumber} as valIsNumber, 
			  %{categorical} as categorical, 
			  %{valIsText} as valIsText
       from ( select * from inputlocaltbl where %{valIsText}= 1)
       where val <> 'NA' and val is not null and val <> ""
) where %{valIsText}= 1

union all
--4. case when val is null
select *
from (  select '%{variable}' as colname,
              "NA" as val,
              "NA" as minval,
              "NA" as maxval,
               1 as S1,
               1 as S2,
               0 as N,
              %{totalcount} as Ntotal,
		      %{valIsNull} as valIsNull, 
			  %{valIsNumber} as valIsNumber, 
			  %{categorical} as categorical, 
			  %{valIsText} as valIsText
		where  %{valIsNull} = 1
)where  %{valIsNull} = 1
); 
