import sys
from os import path
sys.path.append( path.dirname( path.dirname( path.abspath(__file__) ) ) + '/LibraryAlgorithmHelper/' )
from algorithmHelper import TransferData

# Set the data class that will transfer the data between local-global
class Data1(TransferData):
    def __init__(self):
        self.number = 0

    def __add__(self,other):
        addedClass = Data1()
        addedClass.number = self.number + other.number
        return addedClass