requirevars 'defaultDB' 'input_global_tbl' 'columns' 'outputformat';
attach database '%{defaultDB}' as defaultDB;

drop table if exists sumofsquares;
create table sumofsquares as
select sumofsquares(no,formula,sst,ssregs,sse,%{type}) from lala2; --defaultDB.globalAnovatbl;

insert into sumofsquares
select maxno+1, "residuals", sse
from lala2,(select max(no) as maxno from sumofsquares)
where no==maxno;


-- 2. Compute Anova Table
drop table if exists meansquares;
create table meansquares as
select  modelvariables, sumofsquares, df, sumofsquares / df as meansquares
from (select modelvariables,sumofsquares,degreesoffreedom(modelvariables,'%{metadata}') as df
      from sumofsquares);-- where modelvariables<>'intercept' and modelvariables <>'residuals';

update meansquares
set df = 1 where modelvariables ='intercept';
update meansquares
set meansquares = sumofsquares / df where modelvariables ='intercept';

var 'n' from select N from defaultDB.statistics limit 1;
var 'no' from select count(*) from sumofsquares;
update meansquares
set df = %{n} -%{no} + 1 where modelvariables ='residuals'; --WRONG!!!!!

update meansquares
set meansquares = sumofsquares / df where modelvariables ='residuals';


  -- --E5. Compute standardError =sqroot(dSigmaSq*val) ,
  -- --tvalue = estimate/dSigmaSq , p value <-- 2*pt (-abs(t.value), df = length(data)-1)  (Global Layer)
  -- drop table if exists coefficients2;
  -- create table coefficients2 as
  -- select attr, estimate, stderror, tvalue, 2*t_distribution_cdf(-abs(tvalue), var('myrow') - var('mycol')) as prvalue
  -- from (  select attr, estimate, stderror, estimate/stderror as tvalue
  -- 	from (	select coefficients.attr1 as attr,
  --                        estimate,
  --                        sqroot(var('dSigmaSq')*val)  as stderror,
  --                      estimate/sqroot(var('dSigmaSq')*val) as tvalue
  -- 		from defaultDB.coefficients, defaultDB.XTXinverted
  -- 		where coefficients.attr1 = XTXinverted.attr1 and XTXinverted.attr1 = XTXinverted.attr2));
  --
  -- alter table coefficients2 rename to coefficients;
