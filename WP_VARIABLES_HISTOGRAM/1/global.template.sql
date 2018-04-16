requirevars 'input_global_tbl' 'column1' 'column2' 'nobuckets';
attach database '%{defaultDB}' as defaultDB;
---------------------------------------------------------------------------
----Check privacy due to minimum records or large bucket ----
var 'minimumrecords' 10;
var 'containsmorethantheminimumrecords' from 
select case when totalpatients < %{minimumrecords} then 0 else 1 end as containsmorethantheminimumrecords
from ( select sum(patients) as totalpatients
       from %{input_global_tbl}
       where colname = '%{column1}'
	  );
varminimumrec '%{containsmorethantheminimumrecords}';
	  
var 'largenobuckets' from 
select case when totalpatients*0.1<=%{nobuckets} then 0 else 1 end as  largenobuckets
from ( select sum(patients) as totalpatients
       from %{input_global_tbl}
       where colname = '%{column1}'
	  );
largebucket '%{largenobuckets}';

select  colname,
        minvalue,
        maxvalue,
        FARITH('/',S1A,NA) as avgvalue,
        SQROOT( FARITH('/', '-', '*', NA, S2A, '*', S1A, S1A, '*', NA, '-', NA, 1)) as stdvalue
from ( select colname,
              min(minvalue) as minvalue,
              max(maxvalue) as maxvalue,
              FSUM(S1) as S1A,
              FSUM(S2) as S2A,
              sum(N) as NA
       from %{input_global_tbl}
       where colname = '%{column1}'
) where colname = '%{column1}';
