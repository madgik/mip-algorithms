requirevars 'defaultDB' 'input_local_tbl' 'dataset' 'columns' 'classname';

--Input for testing the algorithm
drop table if exists mytable; create table mytable as select * from (file header:t '/root/mip-algorithms/ID3/contact_lenses.csv');
 --var 'input_local_tbl' 'mytable';
-- var 'defaultDB' 'defaultDB';
-- var 'columns' 'age,spectacle-prescrip,astigmatism,tear-prod-rate';
-- var 'classname' 'contact-lenses';
-- var 'outputtype' 'json'; --D3.js
-- var 'dataset' 'adni ';

----------------------------------------------------------------------------------------------------------------
attach database '%{defaultDB}' as defaultDB;

var  'columnsnew' from select create_complex_query("","`?`", "," , "" , '%{columns}');
var 'a' from select create_complex_query("","tonumber(`?`) as `?`", "," , "" , '%{columns}');
drop table if exists defaultDB.localinputtbl;
create table defaultDB.localinputtbl as
select %{a}, tonumber(`%{classname}`) as `%{classname}`
from (select %{columnsnew}, `%{classname}`, dataset from mytable
where dataset in (select strsplitv('%{dataset}','delimiter:,')));

--3.  Delete patients with null values (val is null or val = '' or val = 'NA')
var 'a' from select create_complex_query("","`?` is null or `?`='NA' or `?`=''", "or" , "" , '%{columns}');
delete from defaultDB.localinputtbl where %{a};

--Check if the columns are categorical  TODO!!!!!!

-- Initialize data needed for executing ID3
drop table if exists defaultDB.localinputtblcurrent;
create table defaultDB.localinputtblcurrent as
select * from defaultDB.localinputtbl;

select 'ok';
