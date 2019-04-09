import sys
from os import path
sys.path.append( path.dirname( path.dirname( path.abspath(__file__) ) ) + '/LibraryAlgorithmHelper/' )
import algorithmHelper

# Read the parameters
parameters = algorithmHelper.getParameters(sys.argv[1:])

inputCSV = parameters.get("-local_csv")
if inputCSV == None :
    raise ValueError("local_csv not provided as parameter.")

# Execute the algorithm
sum = 0
sum += 5

# Return the algorithm's output
algorithmHelper.setAlgorithmsOutputData('{"output": "' + str(sum) + '"}')