requirevars 'defaultDB' 'outputformat';

var 'defaultDB' 'defaultDB';
var 'outputformat' 'pfa';
attach database '%{defaultDB}' as defaultDB;

--pfa format (json valid)
setschema 'result'
select * from (totabulardataresourceformat
select no  as `node id`,colname as `node colname`, val as `edge`,nextnode as `next node` from defaultDB.globaltree
) where '%{outputformat}'= 'pfa';
