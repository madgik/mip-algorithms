import sys
from os import path
sys.path.append( path.dirname( path.dirname( path.abspath(__file__) ) ) + '/LibraryAlgorithmHelper/' )
import algorithmHelper

from algorithmLibrary import Data1

# Read the parameters
parameters = algorithmHelper.getParameters(sys.argv[1:])
if not parameters or len(parameters) < 1:
    raise ValueError("There should be 1 parameter")

localDBs = parameters.get("-local_step_dbs")
if localDBs == None :
    raise ValueError("local_step_dbs not provided as parameter.")

# Get the output data from the previous step
data = Data1()
data = data.load(localDBs)

# Execute the algorithm
data.number *= 2

# Return the algorithm's output
algorithmHelper.setAlgorithmsOutputData('{"output": "' + str(data.number) + '"}')
