import requests
import json
import logging
import math

# Required datasets: adni_9rows, adni, data_pr1, desd-synthdata

endpointUrl = 'http://88.197.53.52:9090'


def test_PearsonCorrelation_ADNI_9rows():
    """
    Results from R

    > cor.test(X$leftaccumbensarea, Y$rightaccumbensarea, method="pearson")
    cor = 0.832696403083016, p-value = 0.005332947202092

    > cor.test(X$leftacgganteriorcingulategyrus, Y$rightacgganteriorcingulategyrus, method="pearson")
    cor = 0.764766782355394, p-value = 0.016370022484567

    > cor.test(X$leftainsanteriorinsula, Y$rightainsanteriorinsula, method="pearson")
    cor = 0.928237609063798, p-value 0.000874899301446
    """

    logging.info("---------- TEST : Pearson Correlation ADNI on 9 rows")

    data = [
        {
            "name" : "X",
            "value": "leftaccumbensarea, leftacgganteriorcingulategyrus, leftainsanteriorinsula"
        },
        {
            "name" : "Y",
            "value": "rightaccumbensarea, rightacgganteriorcingulategyrus, rightainsanteriorinsula"
        },
        {
            "name" : "dataset",
            "value": "adni_9rows"
        },
        {
            "name" : "filter",
            "value": ""
        }
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'leftaccumbensarea_rightaccumbensarea', 0.832696403083016, 0.005332947202092
    )
    check_result(
            result['result'][4], 'leftacgganteriorcingulategyrus_rightacgganteriorcingulategyrus',
            0.764766782355394, 0.016370022484567
    )
    check_result(
            result['result'][8], 'leftainsanteriorinsula_rightainsanteriorinsula', 0.928237609063798, 0.000874899301446
    )


def test_PearsonCorrelation_ADNI_alldata():
    """
    Results from R

    > cor.test(X$leftaccumbensarea, Y$rightaccumbensarea, method="pearson")
    cor = 0.911518956593483, p-value = 0.000000000000000

    > cor.test(X$leftacgganteriorcingulategyrus, Y$rightacgganteriorcingulategyrus, method="pearson")
    cor = 0.872706907353685, p-value = 0.000000000000000

    > cor.test(X$leftainsanteriorinsula, Y$rightainsanteriorinsula, method="pearson")
    cor = 0.907680160667781, p-value 0.000000000000000
    """
    logging.info("---------- TEST : Pearson Correlation ADNI on all data")

    data = [
        {
            "name" : "X",
            "value": "leftaccumbensarea, leftacgganteriorcingulategyrus, leftainsanteriorinsula"
        },
        {
            "name" : "Y",
            "value": "rightaccumbensarea, rightacgganteriorcingulategyrus, rightainsanteriorinsula"
        },
        {
            "name" : "dataset",
            "value": "adni"
        },
        {
            "name" : "filter",
            "value": ""
        }
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'leftaccumbensarea_rightaccumbensarea', 0.911518956593483, 0.000000000000000
    )
    check_result(
            result['result'][4], 'leftacgganteriorcingulategyrus_rightacgganteriorcingulategyrus',
            0.872706907353685, 0.000000000000000
    )
    check_result(
            result['result'][8], 'leftainsanteriorinsula_rightainsanteriorinsula', 0.907680160667781, 0.000000000000000
    )


def test_PearsonCorrlation_MIP_AlgoTesting_1():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    lefthippocampus vs righthippocampus
        Pearson's r     0.902
        p-value         < .001
        95% CI Upper    0.913
        95% CI Lower    0.889
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_1")

    data = [
        {
            "name" : "X",
            "value": "lefthippocampus"
        },
        {
            "name" : "Y",
            "value": "righthippocampus"
        },
        {
            "name" : "dataset",
            "value": "desd-synthdata"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'lefthippocampus_righthippocampus', 0.902, 0.000000000000000
    )


def test_PearsonCorrlation_MIP_AlgoTesting_2():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    lefthippocampus vs opticchiasm
        Pearson's r     0.211
        p-value         < .001
        95% CI Upper    0.272
        95% CI Lower    0.148
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_2")

    data = [
        {
            "name" : "X",
            "value": "lefthippocampus"
        },
        {
            "name" : "Y",
            "value": "opticchiasm"
        },
        {
            "name" : "dataset",
            "value": "desd-synthdata"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'lefthippocampus_opticchiasm', 0.211, 0.000000000000000
    )


# def test_PearsonCorrlation_MIP_AlgoTesting_2p1():
#     """
#     Results from 2019_MIP_Algo_Testing/PearsonCorrelation
#
#     subjectageyears vs minimentalstate
#         Pearson's r     -0.149
#         p-value         < .001
#         95% CI Upper    -0.079
#         95% CI Lower    -0.218
#     """
#
#     logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_2p1")
#
#     data = [
#         {
#             "name" : "X",
#             "value": "subjectageyears"
#         },
#         {
#             "name" : "Y",
#             "value": "minimentalstate"
#         },
#         {
#             "name" : "dataset",
#             "value": "desd-synthdata"
#         },
#         {
#             "name" : "filter",
#             "value": ""
#         },
#     ]
#
#     headers = {'Content-type': 'application/json', "Accept": "text/plain"}
#     r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)
#
#     result = json.loads(r.text)
#
#     check_result(
#             result['result'][0], 'subjectageyears_minimentalstate', -0.149, 0.000000000000000
#     )


def test_PearsonCorrlation_MIP_AlgoTesting_3():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    subjectageyears vs opticchiasm
        Pearson's r     -0.006
        p-value          0.867
        95% CI Upper     0.067
        95% CI Lower    -0.079
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_3p1")

    data = [
        {
            "name" : "X",
            "value": "subjectageyears"
        },
        {
            "name" : "Y",
            "value": "opticchiasm"
        },
        {
            "name" : "dataset",
            "value": "desd-synthdata"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'subjectageyears_opticchiasm', -0.006, 0.867
    )


def test_PearsonCorrlation_MIP_AlgoTesting_3p1():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    var1 vs var2
        Pearson's r     -0.006
        p-value          0.867
        95% CI Upper     0.067
        95% CI Lower    -0.079
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_3p1")

    data = [
        {
            "name" : "X",
            "value": "var1"
        },
        {
            "name" : "Y",
            "value": "var2"
        },
        {
            "name" : "dataset",
            "value": "data_pr1"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'var1_var2', -0.006, 0.867
    )


def test_PearsonCorrlation_MIP_AlgoTesting_3p2():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    var3 vs var4
        Pearson's r     0.008
        p-value         0.838
        95% CI Upper    0.081
        95% CI Lower    -0.066
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_3p2")

    data = [
        {
            "name" : "X",
            "value": "var3"
        },
        {
            "name" : "Y",
            "value": "var4"
        },
        {
            "name" : "dataset",
            "value": "data_pr1"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'var3_var4', 0.008, 0.838
    )


def test_PearsonCorrlation_MIP_AlgoTesting_4():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    righthippocampus vs lefthippocampus
        Pearson's r     0.902
        p-value         0.000
        95% CI Upper    0.913
        95% CI Lower    0.889
    righthippocampus vs leftententorhinalarea
        Pearson's r     0.808
        p-value         0.000
        95% CI Upper    0.829
        95% CI Lower    0.784
    lefthippocampus vs leftententorhinalarea
        Pearson's r     0.806
        p-value         0.000
        95% CI Upper    0.828
        95% CI Lower    0.782
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_4")

    data = [
        {
            "name" : "X",
            "value": "righthippocampus, lefthippocampus, leftententorhinalarea"
        },
        {
            "name" : "Y",
            "value": ""
        },
        {
            "name" : "dataset",
            "value": "desd-synthdata"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'righthippocampus_lefthippocampus', 0.902, 0.00
    )
    check_result(
            result['result'][1], 'righthippocampus_leftententorhinalarea', 0.808, 0.00
    )
    check_result(
            result['result'][2], 'lefthippocampus_leftententorhinalarea', 0.806, 0.00
    )


def test_PearsonCorrlation_MIP_AlgoTesting_5():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    righthippocampus vs lefthippocampus
        Pearson's r     0.902
        p-value         0.000
        95% CI Upper    0.913
        95% CI Lower    0.889
    righthippocampus vs opticchiasm
        Pearson's r     0.198
        p-value         0.000
        95% CI Upper    0.259
        95% CI Lower    0.135
    lefthippocampus vs opticchiasm
        Pearson's r     0.211
        p-value         0.000
        95% CI Upper    0.272
        95% CI Lower    0.148
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_5")

    data = [
        {
            "name" : "X",
            "value": "righthippocampus, lefthippocampus, opticchiasm"
        },
        {
            "name" : "Y",
            "value": ""
        },
        {
            "name" : "dataset",
            "value": "desd-synthdata"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'righthippocampus_lefthippocampus', 0.902, 0.00
    )
    check_result(
            result['result'][1], 'righthippocampus_opticchiasm', 0.198, 0.00
    )
    check_result(
            result['result'][2], 'lefthippocampus_opticchiasm', 0.211, 0.00
    )


def test_PearsonCorrlation_MIP_AlgoTesting_6():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    lefthippocampus vs subjectageyears
        Pearson's r     -0.208
        p-value         0.000
        95% CI Upper    -0.137
        95% CI Lower    -0.277
    lefthippocampus vs opticchiasm
        Pearson's r     0.202
        p-value         0.000
        95% CI Upper    0.271
        95% CI Lower    0.130
    subjectageyears vs opticchiasm
        Pearson's r     -0.006
        p-value         0.867
        95% CI Upper    0.067
        95% CI Lower    -0.079
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_6")

    data = [
        {
            "name" : "X",
            "value": "lefthippocampus, subjectageyears, opticchiasm"
        },
        {
            "name" : "Y",
            "value": ""
        },
        {
            "name" : "dataset",
            "value": "desd-synthdata"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'lefthippocampus_subjectageyears', -0.208, 0.00
    )
    check_result(
            result['result'][1], 'lefthippocampus_opticchiasm', 0.202, 0.00
    )
    check_result(
            result['result'][2], 'subjectageyears_opticchiasm', -0.006, 0.867
    )


def test_PearsonCorrlation_MIP_AlgoTesting_7():
    """
    Results from 2019_MIP_Algo_Testing/PearsonCorrelation

    subjectageyears vs lefthippocampus
        Pearson's r     -0.208
        p-value         0.000
        95% CI Upper    -0.137
        95% CI Lower    -0.277
    lefthippocampus vs opticchiasm
        Pearson's r     0.202
        p-value         0.000
        95% CI Upper    0.271
        95% CI Lower    0.130
    subjectageyears vs opticchiasm
        Pearson's r     -0.006
        p-value         0.867
        95% CI Upper    0.067
        95% CI Lower    -0.079
    """

    logging.info("---------- TEST : Pearson Correlation MIP_Algo_Testing_6")

    data = [
        {
            "name" : "X",
            "value": "subjectageyears, lefthippocampus, opticchiasm"
        },
        {
            "name" : "Y",
            "value": ""
        },
        {
            "name" : "dataset",
            "value": "desd-synthdata"
        },
        {
            "name" : "filter",
            "value": ""
        },
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    check_result(
            result['result'][0], 'subjectageyears_lefthippocampus', -0.208, 0.00
    )
    check_result(
            result['result'][1], 'subjectageyears_opticchiasm', -0.006, 0.867
    )
    check_result(
            result['result'][2], 'lefthippocampus_opticchiasm', 0.202, 0.00
    )


def check_result(my_result, r_var_pair, r_corr, r_pval):
    var_pair = my_result['Variable pair']
    corr = float(my_result['Pearson correlation coefficient'])
    pval = float(my_result['p-value'])
    assert var_pair == r_var_pair
    assert math.isclose(corr, r_corr, rel_tol=0, abs_tol=1e-03)
    assert math.isclose(pval, r_pval, rel_tol=0, abs_tol=1e-03)
