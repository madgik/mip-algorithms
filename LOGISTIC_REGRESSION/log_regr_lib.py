from __future__ import division
from __future__ import print_function

import sys
from os import path

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))) + '/utils/')
from algorithm_utils import TransferData


class LogRegrInit_Loc2Glob_TD(TransferData):
    def __init__(self, *args):
        if len(args) != 2:
            raise ValueError('illegal arguments')
        self.n_obs = args[0]
        self.n_cols = args[1]

    def get_data(self):
        return self.n_obs, self.n_cols

    def __add__(self, other):
        if self.n_cols != other.n_cols:
            raise ValueError('local n_cols do not agree')
        return LogRegrInit_Loc2Glob_TD((
            self.n_obs + other.n_obs,
            self.n_cols
        ))

class LogRegrIter_Loc2Glob_TD(TransferData):
    def __init__(self, *args):
        if len(args) != 3:
            raise ValueError('illegal arguments')
        self.ll = args[0]
        self.gradient = args[1]
        self.hessian = args[2]

    def get_data(self):
        return self.ll, self.gradient, self.hessian

    def __add__(self, other):
        if len(self.gradient) != len(other.gradient):
            raise ValueError('local gradient sizes do not agree')
        if self.hessian.shape != other.hessian.shape:
            raise ValueError('local Hessian sizes do not agree')
        return LogRegrIter_Loc2Glob_TD((
            self.ll + other.ll,
            self.gradient + other.gradient,
            self.hessian + other.hessian
        ))

class LogRegrIter_Glob2Loc_TD(TransferData):
    def __init__(self, *args):
        if len(args) != 1:
            raise ValueError('illegal arguments')
        self.coeffs = args[0]

    def get_data(self):
        return self.coeffs


