import sys
import math
import json
from os import path
import numpy as np
import scipy.special as special
from argparse import ArgumentParser

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/utils/')

from algorithm_utils import set_algorithms_output_data
from pearsonc_lib import PearsonCorrelationLocalDT


def pearsonc_global(global_in):
    nn, sx, sy, sxx, sxy, syy, schema_X, schema_Y = global_in.get_data()
    n_cols = len(nn)
    schema_out = [None] * n_cols
    result_list = []
    for i in xrange(n_cols):
        schema_out[i] = schema_X[i] + '_' + schema_Y[i]
        # Compute pearson correlation coefficient and p-value
        if nn[i] == 0:
            r = None
            prob = None
        else:
            d = (math.sqrt(nn[i] * sxx[i] - sx[i] * sx[i]) * math.sqrt(nn[i] * syy[i] - sy[i] * sy[i]))
            if d == 0:
                r = 0
            else:
                r = float((nn[i] * sxy[i] - sx[i] * sy[i]) / d)
            r = max(min(r, 1.0), -1.0)  # if abs(r) > 1 correct: artifact of floating point arithmetic.
            df = nn[i] - 2
            if abs(r) == 1.0:
                prob = 0.0
            else:
                t_squared = r ** 2 * (df / ((1.0 - r) * (1.0 + r)))
                prob = special.betainc(
                        0.5 * df, 0.5, np.fmin(np.asarray(df / (df + t_squared)), 1.0)
                )
        result_list.append({
            'Variable pair'                  : schema_out[i],
            'Pearson correlation coefficient': r,
            'p-value'                        : prob if prob >= 0.001 else 0.0
        })
    global_out = json.dumps({'result': result_list})
    return global_out


def main():
    # Parse arguments
    parser = ArgumentParser()
    parser.add_argument('-local_step_dbs', required=True, help='Path to local db.')
    args, unknown = parser.parse_known_args()
    local_dbs = path.abspath(args.local_step_dbs)

    local_out = PearsonCorrelationLocalDT.load(local_dbs)
    # Run algorithm global step
    global_out = pearsonc_global(global_in=local_out)
    # Return the algorithm's output
    set_algorithms_output_data(global_out)


if __name__ == '__main__':
    main()
