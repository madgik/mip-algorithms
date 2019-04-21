from __future__ import division
from __future__ import print_function

import sys
import sqlite3
from os import path

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/utils/')
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/LOGISTIC_REGRESSION/')

import numpy as np

from algorithm_utils import get_parameters, StateData
from log_regr_lib import LogisticRegressionInit_L2G_TD

def logregr_local_init(X, Y, schema_X, schema_Y):
    n_obs = len(Y)
    n_cols = len(X[0])

    local_state = StateData(n_obs=n_obs, n_cols=n_cols)
    local_out = LogisticRegressionInit_L2G_TD(n_obs, n_cols)
    return local_state, local_out


def main():
    # read parameters
    parameters = get_parameters(sys.argv[1:])
    if not parameters or len(parameters) < 1:
        raise ValueError("There should be 1 parameter")
    # get current state pickle path
    cur_state_pkl = parameters.get("-cur_state_pkl")
    if cur_state_pkl is None:
        raise ValueError("cur_state_pkl not provided as parameter.")
    # get db path
    fname_db = parameters.get("-input_local_DB")
    if fname_db is None:
        raise ValueError("input_local_DB not provided as parameter.")
    # get query
    query = parameters['-db_query']
    if query is None:
        raise ValueError('db_query not provided as parameter.')
    # read formula from csv file
    conn = sqlite3.connect(fname_db)
    cur = conn.cursor()
    c = cur.execute(query)
    schema = [description[0] for description in cur.description]

    n_cols = len(schema) - 1
    data = np.array(cur.fetchall(), dtype=np.float64)
    schema_Y, schema_X = schema[0], schema[1:]
    Y, X = data[:, 0], data[:, 1:]

    # run algorithm local step
    local_state, local_out = logregr_local_init(X, Y, schema_X, schema_Y)

    # save state locally
    local_state.save(fname=cur_state_pkl)

    # return the output formula (should be the last command)
    local_out.transfer()


if __name__ == '__main__':
    main()
