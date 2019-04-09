import sys
from os import path
sys.path.append( path.dirname( path.dirname( path.abspath(__file__) ) ) + '/LibraryAlgorithmHelper/' )
import algorithmHelper

from algorithmLibrary import Data1

# Read the parameters
parameters = algorithmHelper.getParameters(sys.argv[1:])
if not parameters or len(parameters) < 1:
    raise ValueError("There should be 1 parameter")

inputCSV = parameters.get("-local_csv")
if inputCSV == None :
    raise ValueError("local_csv not provided as parameter.")

# Execute the algorithm
data = Data1()
data.number = 1

# Return the output data (Should be the last command)
data.transfer()