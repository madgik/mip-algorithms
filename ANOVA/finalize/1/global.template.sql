requirevars 'defaultDB' 'type' 'input_global_tbl' 'metadata' 'outputformat';
attach database '%{defaultDB}' as defaultDB;

--var 'input_global_tbl' 'defaultDB.metadatatbl';
----------

var 'metadata' from select jgroup(code,enumerations) from (select distinct code ,enumerations from %{input_global_tbl});

drop table if exists sumofsquares;
create table sumofsquares as
select sumofsquares(no,formula,sst,ssregs,sse,%{type}) from defaultDB.globalAnovatbl;

var 'a' from select max(no) from sumofsquares;
insert into sumofsquares
select %{a}+1, "residuals", sse
from defaultDB.globalAnovatbl,(select max(no) as maxno from defaultDB.globalAnovatbl)
where no==maxno;

var 'N' from select N from defaultDB.statistics limit 1;
drop table if exists defaultDB.globalresult;
create table defaultDB.globalresult as
select modelvariables as `model variables`, sumofsquares as `sum of squares`, df as `Df`, meansquare as `mean square`,
        f as`f`,p as`p`,etasquared as`eta squared`,partetasquared as`part eta squared`, omegasquared as `omega squared`
                from (select anovastatistics(no, modelvariables, sumofsquares, '%{metadata}',%{N} ) from sumofsquares);


setschema 'result'
select * from (totabulardataresourceformat title:ANOVA_TABLE types:text,number,number,number,number,number,number,number,number
                select *from defaultDB.globalresult) where '%{outputformat}'= 'pfa';
