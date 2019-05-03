from __future__ import division
from __future__ import print_function

import sys
import sqlite3
from os import path
from argparse import ArgumentParser

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/utils/')
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/LOGISTIC_REGRESSION/')

import numpy as np

from algorithm_utils import StateData
from log_regr_lib import LogRegrInit_Loc2Glob_TD


def logregr_local_init(local_in):
    # Unpack local input
    X, Y, schema_X, schema_Y = local_in

    n_obs = len(Y)
    n_cols = len(X[0])

    # Pack state and results
    local_state = StateData(n_obs=n_obs, n_cols=n_cols, X=X, Y=Y, schema_X=schema_X, schema_Y=schema_Y)
    local_out = LogRegrInit_Loc2Glob_TD(n_obs, n_cols)
    return local_state, local_out


def main():
    # Parse arguments
    parser = ArgumentParser()
    parser.add_argument('-s', '-cur_state_pkl', required=True,
                        help='Path to the pickle file holding the current state.')
    parser.add_argument('-d', '-input_local_DB', required=True,
                        help='Path to local db.')
    parser.add_argument('-q', '-db_query', required=True,
                        help='Query to be executed on local db.')
    args = parser.parse_args()
    fname_cur_state = path.abspath(args.cur_state_pkl)
    fname_loc_db = path.abspath(args.input_local_DB)
    query = args.db_query

    # Get data from local DB
    conn = sqlite3.connect(fname_loc_db)
    cur = conn.cursor()
    cur.execute(query)
    schema = [description[0] for description in cur.description]
    data = np.array(cur.fetchall(), dtype=np.float64)
    schema_Y, schema_X = schema[0], schema[1:]
    Y, X = data[:, 0], data[:, 1:]

    local_in = X, Y, schema_X, schema_Y
    # Run algorithm local step
    local_state, local_out = logregr_local_init(local_in=local_in)
    # Save local state
    local_state.save(fname=fname_cur_state)
    # Transfer local output (should be the last command)
    local_out.transfer()


if __name__ == '__main__':
    main()
