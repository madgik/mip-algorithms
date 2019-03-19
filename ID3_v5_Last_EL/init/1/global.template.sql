requirevars 'defaultDB' 'input_global_tbl' 'classname' ;
attach database '%{defaultDB}' as defaultDB;

drop table if exists defaultdb.globaltree;
create table defaultdb.globaltree(no int, colname text, val text, nextnode text);

drop table if exists defaultdb.globalpathforsplittree;
create table defaultdb.globalpathforsplittree (no int, colname text, val text, nextnode text);

select 'ok';
