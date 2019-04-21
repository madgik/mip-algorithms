from __future__ import division
from __future__ import print_function

import sys
import sqlite3
from os import path

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/utils/')
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/LOGISTIC_REGRESSION/')

import numpy as np

from algorithm_utils import get_parameters, set_algorithms_output_data, StateData
from log_regr_lib import LogisticRegressionInit_L2G_TD, LogistiRegressionIter_G2L_TD

def logregr_global_init(global_in):
    n_obs, n_cols = global_in.get_data()

    # init vars
    ll_glob = - 2 * n_obs * np.log(2)
    coeff = np.zeros(n_cols)
    global_state = StateData(n_obs=n_obs, n_cols=n_cols, ll_glob=ll_glob, coeff=coeff)
    global_out = LogistiRegressionIter_G2L_TD(coeff)

    return global_state, global_out


def main():
    # read parameters
    parameters = get_parameters(sys.argv[1:])
    if not parameters or len(parameters) < 1:
        raise ValueError("There should be 1 parameter")
    # get formula from local db
    localdbs = parameters.get("-local_step_dbs")
    if localdbs == None:
        raise ValueError("local_step_dbs not provided as parameter.")
    local_out = LogisticRegressionInit_L2G_TD.load(localdbs)
    # get current state pickle path
    cur_state_pkl = parameters.get("-cur_state_pkl")
    if cur_state_pkl is None:
        raise ValueError("cur_state_pkl not provided as parameter.")
    # run algorithm global step
    global_state, global_out = logregr_global_init(global_in=local_out)
    # return the algorithm's output
    set_algorithms_output_data(global_out)


if __name__ == '__main__':
    main()
