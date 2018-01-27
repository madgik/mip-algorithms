requirevars 'defaultDB' 'input_global_tbl';
attach database '%{defaultDB}' as defaultDB;

--hidden var 'input_global_tbl' 'resultlocal1';
--drop table if exists resultglobal1;
--create table resultglobal1 as

select  colname,
        FARITH('/',S1A,NA) as avgvalue
from ( select colname,
              FSUM(S1) as S1A,
              SUM(N) as NA
        from %{input_global_tbl}
        group by colname );


