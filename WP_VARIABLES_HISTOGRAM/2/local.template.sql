requirevars 'defaultDB' 'prv_output_global_tbl' 'column1' 'column2' 'nobuckets';
attach database '%{defaultDB}' as defaultDB;

select heatmaphistogrampoc(colname1,val1,minval1,maxval1,buckets1,colname2,val2,distinctvalues2)
from  ( select colname1, val1, %{nobuckets} as buckets1, colname2, val2
        from (select rid as rid1 ,colname as colname1, val as val1 from defaultDB.inputlocaltbl where colname = '%{column1}' and '%{column2}' <> ''),
             (select rid as rid2 ,colname as colname2, val as val2 from defaultDB.inputlocaltbl where colname = '%{column2}' and '%{column2}' <> '')
        where rid1 = rid2
		union all
		select colname1, val1, %{nobuckets} as buckets1,null as colname2, null as val2
        from (select rid as rid1 ,colname as colname1, val as val1 from defaultDB.inputlocaltbl where colname = '%{column1}'and '%{column2}' = '')
      ),
      ( select minvalue as minval1, maxvalue as maxval1 from %{prv_output_global_tbl}),
      ( select case when '%{column2}' = '' then  null else jgroup(val) end as distinctvalues2
        from ( select val from defaultDB.inputlocaltbl where colname = '%{column2}' group by val)
	  )
order by id0, id1; 
