requirevars 'defaultDB' 'input_global_tbl' 'classname' ;
attach database '%{defaultDB}' as defaultDB;

--var 'input_global_tbl' 'localcounts';
----------------------------------------------------------------------------------------------------------
-- Merge local_counts
drop table if exists globalcounts;
create table  globalcounts as
select  colname, val, classval, sum(quantity) as quantity
from %{input_global_tbl}
group by colname, classval,val;

--Compute gain
drop table if exists gain;
create table gain as
select colname, max(sumofentropies) from (
    select colname, sum(nentropy)/sum(n) as sumofentropies
    from( select colname, val, n,  sumnlong - n* pyfun('math.log', n ,2)  as nentropy
          from( select colname, val, sum(quantity) as n, sum(quantity * pyfun('math.log', quantity ,2)) as sumnlong
                from globalcounts
                group by colname, val )
          where colname!=var('classname')
        )
    group by colname
);

--2. Find new nodes of tree and update global_tree
drop table if exists globalnewnodesoftree;
create table globalnewnodesoftree (no int,colname text,val text, nextnode text);
insert into  globalnewnodesoftree
select no, colname, val, nextnode
from ( select distinct colname, val, case when count(*) = 1 then classval else '?' end as nextnode
       from globalcounts where colname in (select colname from gain)
       group by colname,val),
     ( select case when no is null then '1' else cast(max(no)+1 as text)   end as no from defaultdb.globaltree );

select * from globalnewnodesoftree;

update defaultdb.globaltree set nextnode = (select no from globalnewnodesoftree)
where  jmerge(no,colname,val) is (select jmerge (no,colname,val) from globalpathforsplittree);

insert into defaultdb.globaltree select * from globalnewnodesoftree;

--3. Find the path in order to split the input dataset/table
drop table if exists globalpathforsplittree;
create table globalpathforsplittree as
pathtree value:? select * from defaultdb.globaltree;

select * from globalpathforsplittree;
