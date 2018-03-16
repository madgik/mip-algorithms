requirevars 'input_global_tbl' 'columns' 'k' 'defaultDB';
attach database '%{defaultDB}' as defaultDB;

select case when sum(patients)*0.1<=%{k} then 0 else 1 end as res from %{input_global_tbl};
