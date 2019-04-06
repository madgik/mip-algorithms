import sys
from os import path
sys.path.append( path.dirname( path.dirname( path.abspath(__file__) ) ) + '/LibraryAlgorithmHelper/' )
import algorithmHelper

# Set the data class that will transfer the data between local-global
class DataTransferClass():
    def __init__(self):
        self.number = 0

# Read the parameters
parameters = algorithmHelper.getParameters(sys.argv[1:])
if not parameters or len(parameters) < 1:
	raise ValueError("There should be 1 parameter")

inputCSV = parameters.get("-input_local_csv")
if inputCSV == None :
	raise ValueError("input_local_csv not provided as parameter.")

# Execute the algorithm
data = DataTransferClass()
data.number = 1


# Return the output data (Should be the last command)
algorithmHelper.setTransferData(data)