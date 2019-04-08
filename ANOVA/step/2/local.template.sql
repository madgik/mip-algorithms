requirevars 'defaultDB' 'x' 'y' 'prv_output_global_tbl' 'dataset';
attach database '%{defaultDB}' as defaultDB;

var 'prv_output_global_tbl' 'defaultDB.g.s defaultDBlobalresult'; -- statistics & coefficients

--E1. Compute residuals y-ypredictive = Y-sum(X(i)*estimate(i)) (Local Layer)
var 'a' from select tabletojson(attr1,estimate,"attr1,estimate") from defaultDB.globalresult where tablename ="coefficients";
var 'grandmean' from select mean as mean_observed_value from %{prv_output_global_tbl} where tablename ="statistics" and colname = '%{y}';

drop table if exists defaultDB.residuals;
create table defaultDB.residuals as
residualscomputation coefficients:%{a} y:%{y} select * from input_local_tbl_LR_Final;
hidden var 'partial_sse' from select sum(val*val) from defaultDB.residuals;

hidden var 'partial_sst' from
select sum( (%{y}-%{grandmean})*(%{y}-%{grandmean}))
from defaultdb.localinputtblflat;

drop table if exists localsss;
create table localsss as
select '%{partial_sst}' as sst,'%{partial_sse}' as sse;

select * from localsss;




-- select rid1, observed_value - predicted_value as e
-- from ( select rid as rid1, sum(val*estimate) as predicted_value
--        from defaultDB.input_local_tbl_LR_Final,
--        (select attr1,estimate from %{prv_output_global_tbl} where tablename ="coefficients")
--        where colname = attr1
--        group by rid ),
--      ( select rid as rid2, val as observed_value
--         from defaultDB.input_local_tbl_LR_Final
--        where colname = "%{y}" )
-- where rid1=rid2;
--
-- hidden var 'partial_sse' from select sum(e*e) from defaultDB.residuals;
--
-- hidden var 'partial_sst' from setschema 'c1'
-- select sum( (val-mean_observed_value)*(val-mean_observed_value))
-- from input_local_tbl_LR_Final,
--      ( select mean as mean_observed_value
--        from %{prv_output_global_tbl}
--        where tablename ="statistics"
--        and colname = '%{y}')
-- where colname = '%{y}';
