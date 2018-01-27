requirevars 'defaultDB' 'prv_output_global_tbl' 'y';
attach database '%{defaultDB}' as defaultDB;


--hidden var 'prv_output_global_tbl' 'resultglobal2';

--E. Compute statistics For Estimators ( standardError ,  tvalue  , p value )
--E1. Compute residuals y-ypredictive = Y-sum(X(i)*estimate(i)) (Local Layer)
drop table if exists defaultDB.residuals;
create table defaultDB.residuals as
select rid1, observed_value - predicted_value as e
from ( select rid as rid1, sum(val*estimate) as predicted_value
       from defaultDB.input_local_tbl_LR_Final, %{prv_output_global_tbl}
       where colname = attr1
       group by rid ),
     ( select rid as rid2, val as observed_value
        from defaultDB.input_local_tbl_LR_Final
       where colname = "%{y}" )
where rid1=rid2;


--drop table if exists resultlocal3;
--create table resultlocal3 as
select rowid as rid1,e from defaultDB.residuals;


