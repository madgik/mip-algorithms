from __future__ import division
from __future__ import print_function

import sys
import sqlite3
from os import path
from argparse import ArgumentParser

import numpy as np

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/utils/')
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/LOGISTIC_REGRESSION/')

from algorithm_utils import StateData
from log_regr_lib import LogRegrInit_Loc2Glob_TD


def logregr_local_init(local_in):
    # Unpack local input
    data, schema = local_in
    schema_Y, schema_X = schema[0], schema[1:]
    X = np.array(data[:, 1:], dtype=np.float64)
    Y = data[:, 0]
    assert len(set(Y)) == 2, "Y vector should only contain 2 distinct values"
    y_val_dict = {
        sorted(set(Y))[0]: 0,
        sorted(set(Y))[1]: 1
    }
    Y = np.array([y_val_dict[yi] for yi in Y], dtype=np.int)

    n_obs = len(Y)
    n_cols = len(X[0])

    # Pack state and results
    local_state = StateData(X=X, Y=Y)
    local_out = LogRegrInit_Loc2Glob_TD(n_obs, n_cols, y_val_dict, schema_X, schema_Y)
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
    data = cur.fetchall()

    local_in = data, schema
    # Run algorithm local step
    local_state, local_out = logregr_local_init(local_in=local_in)
    # Save local state
    local_state.save(fname=fname_cur_state)
    # Transfer local output (should be the last command)
    local_out.transfer()


if __name__ == '__main__':
    main()
