requirevars 'defaultDB' 'input_local_tbl' 'x' 'y' 'dataset';
-- to y einai real
-- to x einai equation me categorical values . Mporei na periexei ta sumbola +-* kai tous arithmous 1,0
-- to type einai o typos (1,2,3) gia to sum of squares
-------------------------------------------------------------------------------
-----------------------  Input for testing ------------------------------------

-- hidden var 'defaultDB' defaultDB_ANOVA;
-- hidden var 'y' 'ANOVA_var_D';
-- hidden var 'x' 'ANOVA_var_I1*ANOVA_var_I2*ANOVA_var_I3';
-- hidden var 'type' 2;
-- hidden var 'outputformat' 'pfa';

hidden var 'dataset' 'datasetAnova';

-- Import dataset
hidden var 'csvfileofinputlocaltbl' '/root/mip-algorithms/ANOVA/Unbalanced1.csv';
drop table if exists table1;
create table table1 as
select * from (file header:t '%{csvfileofinputlocaltbl}');
hidden var 'input_local_tbl' 'table1';

------------------ End input for testing
------------------------------------------------------------------------------
attach database '%{defaultDB}' as defaultDB;

hidden var 'metadatafilename' '/root/mip-algorithms/ANOVA/variablesMetadata.json';

drop table if exists datasets;
create table datasets as
select strsplitv('%{dataset}','delimiter:,') as d;

drop table if exists xvariables;
create table xvariables as
-- select strsplitv(regexpr("\+|\:|\*|\-",'%{x}',"+") ,'delimiter:+') as xname;
select xname from (select strsplitv(regexpr("\+|\:|\*|\-",'%{x}',"+") ,'delimiter:+') as xname) where xname!=0 ;


drop table if exists defaultDB.metadatatbl;
create table defaultDB.metadatatbl as
select code,enumerations from (readmetadatafile filename:%{metadatafilename})
where code in (select * from xvariables);


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

select "ok";
