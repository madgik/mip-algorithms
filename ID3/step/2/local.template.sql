requirevars 'defaultDB' 'prv_output_global_tbl' 'classname';

--var 'prv_output_global_tbl' 'globalpathforsplittree';

--- Split initial dataset based on global_pathforsplittree
var 'filters' from select tabletojson(colname,val, "colname,val") from %{prv_output_global_tbl};
drop table if exists defaultDB.localinputtblcurrent;
create table defaultDB.localinputtblcurrent as
filtertable filters:%{filters} select * from defaultDB.localinputtbl;

select 'ok';

select * from defaultDB.globaltree;
