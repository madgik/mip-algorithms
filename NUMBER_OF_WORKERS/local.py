import sys
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

inputCSV = opts.get("-input_local_csv")
if inputCSV == None :
	raise ValueError("input_local_csv not provided as parameter.")






data = MyData()
data.number = 1


print codecs.encode(pickle.dumps(data), "base64")