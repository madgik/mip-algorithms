requirevars 'defaultDB' 'input_local_tbl' 'input_local_metadata' 'x' 'y' 'dataset';
-- To input_local_metadata einai ena table ths morfhs:  columnname, type, values (in case of categorical)
-- to y einai real
-- to x einai equation me categorical values . Mporei na periexei ta sumbola +-* kai tous arithmous 1,0
-- to type einai o typos (1,2,3) gia to sum of squares

-----------------------------------------------------------------------------
---------------------Input for testing
hidden var 'input_local_tbl' 'table1';
hidden var 'input_local_metadata'  'metadata_tbl';
hidden var 'defaultDB' defaultDB_ANOVA;
hidden var 'y' 'var_D';
hidden var 'x' 'var_I1*var_I2*var_I3';
hidden var 'dataset' 'all';
hidden var 'metadata' '{"var_I1":[0,1,2],"var_I2":[0,1,2],"var_I3":[0,1]}';
hidden var 'csvfileofinputlocaltbl' 'data_ANOVA_Unbalanced_with_inter_V1V2_copy.csv';
hidden var 'type' 1;

-- Import dataset
drop table if exists table1;
create table table1 as
select *,'all' as dataset from (file header:t '%{csvfileofinputlocaltbl}');
--select * from table1;
------------------ End input for testing
------------------------------------------------------------------------------
attach database '%{defaultDB}' as defaultDB;

drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

drop table if exists xvariables;
create table xvariables as
-- select strsplitv(regexpr("\+|\:|\*|\-",'%{x}',"+") ,'delimiter:+') as xname;
select xname from (select strsplitv(regexpr("\+|\:|\*|\-",'%{x}',"+") ,'delimiter:+') as xname) where xname!=0 ;

var 'xnames' from select group_concat(xname) as  xname from (select distinct xname from xvariables); -- TODO Add distinct to the rest of the algorithms!!

--1. Keep only the correct columns of the table : x,y, dataset
drop table if exists localinputtbl_1;
create table localinputtbl_1 as select %{xnames}, %{y}, dataset from %{input_local_tbl}
where dataset in (select * from datasets);

--2.  Delete patients with null values (val is null or val = '' or val = 'NA')
var 'a' from select create_complex_query("","? is null or ?='NA' or ?=''", "or" , "" , '%{xnames}');
delete from localinputtbl_1 where %{a} or %{y} is null or %{y}='NA' or %{y}='' ;

--2. Cast values of columns using cast function. Keep the rows of the correct dataset.
var 'cast_xnames' from select create_complex_query("","cast(? as text) as ?", "," , "" , '%{xnames}');
drop table if exists defaultDB.localinputtblflat;
create table defaultDB.localinputtblflat as
select %{cast_xnames}, cast(%{y} as real) as '%{y}', cast(1.0 as real) as intercept from localinputtbl_1  --TODO . Do not use tonumber but do cast based on the metadata
where dataset in (select * from datasets);

drop table if exists defaultDB.localinputtbleav;
create table defaultDB.localinputtbleav as
select rid,colname, val from (toeav select * from defaultDB.localinputtblflat);

drop table if exists table1;
drop table if exists datasets;
drop table if exists xvariables;
drop table if exists localinputtbl_1;

select "ok";
