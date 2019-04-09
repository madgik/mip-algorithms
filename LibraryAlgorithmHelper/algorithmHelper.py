import sqlite3
import pickle
import codecs


class TransferData():
    def __add__(self, other):
        raise NotImplementedError('The __add__ method should be implemented by the child class.')

    @classmethod
    def load(cls,inputDB):
        conn = sqlite3.connect(inputDB)
        cur = conn.cursor()

        cur.execute('SELECT results FROM transfer')

        output = cls()
        for row in cur:
            result = pickle.loads(codecs.decode(row[0], 'base64'))
            output += result
        return output

    def transfer(self):
        print codecs.encode(pickle.dumps(self), 'base64')


def getParameters(argv):
    opts = {}
    while argv:
        if argv[0][0] == '-':
            opts[argv[0]] = argv[1]
            argv = argv[2:]
        else:
            argv = argv[1:]
    return opts


def setAlgorithmsOutputData(data):
    print data