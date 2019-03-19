requirevars 'defaultDB' ;

--pfa format (json valid)
select id3resultsviewer(nonode, nodecolname,edge,nextnode)
setschema 'result'
select * from (totabulardataresourceformat
select no as `node id`,colname as `node colname`, val as `edge`,nextnode as `next node` from defaultDB.globaltree
) where '%{outputformat}'= 'pfa';
