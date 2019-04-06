import sys
import sqlite3
import pickle
import codecs

class MyData():
    def __init__(self):
        self.number = 0

def getopts(argv):
    opts = {}
    while argv:
        if argv[0][0] == '-':
            opts[argv[0]] = argv[1]
            argv = argv[2:]
        else:
            argv = argv[1:]
    return opts
	
args = sys.argv[1:]
opts = getopts(args)
if not opts or len(opts) < 1:
	raise ValueError("There should be 1 parameter")

inputDB = opts.get("-input_db")
if inputDB == None :
	raise ValueError("input_db not provided as parameter.")

conn = sqlite3.connect(inputDB)
cur = conn.cursor()

cur.execute('SELECT results FROM test')

sum = 0
for row in cur:
	data = pickle.loads(codecs.decode(row[0], "base64")) 
	sum += data.number

print('{"output": "' + str(sum) + '"}')
