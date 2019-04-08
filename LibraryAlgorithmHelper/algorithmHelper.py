import sqlite3
import pickle
import codecs

def getParameters(argv):
    opts = {}
    while argv:
        if argv[0][0] == '-':
            opts[argv[0]] = argv[1]
            argv = argv[2:]
        else:
            argv = argv[1:]
    return opts
	
	
def getTransferedData(inputDB):
	conn = sqlite3.connect(inputDB)
	cur = conn.cursor()

	cur.execute('SELECT results FROM transfer')

	results = []
	for row in cur:
		results.append(pickle.loads(codecs.decode(row[0], "base64")))
	
	return results

def setTransferData(data):
	print codecs.encode(pickle.dumps(data), "base64")
	
def setAlgorithmsOutputData(data):
	print data