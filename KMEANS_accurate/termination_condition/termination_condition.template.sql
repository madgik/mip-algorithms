requirevars 'defaultDB' 'input_local_tbl' 'columns' 'k' 'e';
attach database '%{defaultDB}' as defaultDB;

 update iterationsDB.iterations_condition_check_result_tbl set iterations_condition_check_result = (
   select  max(diff)> %{e}
   from ( select abs(clold.clval - clnew.clval) as diff
          from defaultDB.clustercenters_global as clold,
               defaultDB.clustercentersnew_global as clnew
          where clold.clid = clnew.clid and clold.clcolname = clnew.clcolname)
);

select "ok";
