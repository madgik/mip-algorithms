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

inputDB = parameters.get("-input_db")
if inputDB == None :
	raise ValueError("input_db not provided as parameter.")

# Get the output data from the previous step
data = algorithmHelper.getTransferedData(inputDB)

# Execute the algorithm
sum = 0
for dataTransferObject in data:
	sum += dataTransferObject.number

# Return the algorithm's output
algorithmHelper.setAlgorithmsOutputData('{"output": "' + str(sum) + '"}')
