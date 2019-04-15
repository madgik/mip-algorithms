import requests
import json
import logging
import math

# Required datasets: adni_10rows

endpointUrl = 'http://88.197.53.100:9090'


def test_PearsonCorrelation_ADNI_1():
    logging.info("---------- TEST : Pearson Correlation ADNI 1")

    data = [
        {
            "name" : "X",
            "value": "leftaccumbensarea, leftacgganteriorcingulategyrus, leftainsanteriorinsula"
        },
        {
            "name" : "X",
            "value": "rightaccumbensarea, rightacgganteriorcingulategyrus, rightainsanteriorinsula"
        },
        {
            "name" : "dataset",
            "value": "adni_10rows"
        },
        {
            "name" : "filter",
            "value": ""
        }
    ]

    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    r = requests.post(endpointUrl + '/mining/query/PEARSON_CORRELATION', data=json.dumps(data), headers=headers)

    result = json.loads(r.text)

    """
    Results from R  
    
    > cor.test(X$leftaccumbensarea, Y$rightaccumbensarea, method="pearson")
    cor = 0.8050372, p-value = 0.004959 
    
    > cor.test(X$leftacgganteriorcingulategyrus, Y$rightacgganteriorcingulategyrus, method="pearson")
    cor = 0.7524994, p-value = 0.01203 
    
    > cor.test(X$leftainsanteriorinsula, Y$rightainsanteriorinsula, method="pearson")
    cor = 0.9434271, p-value 4.184e-05 
    """

    check_result(
            result['result'][0], 'leftaccumbensarea_rightaccumbensarea', 0.8050372, 0.004959
    )
    check_result(
            result['result'][1], 'leftacgganteriorcingulategyrus_rightacgganteriorcingulategyrus',
            0.7524994, 0.01203
    )
    check_result(
            result['result'][2], 'leftainsanteriorinsula_rightainsanteriorinsula', 0.9434271, 4.184e-05
    )


def check_result(r_result, r_var_pair, r_corr, r_pval):
    var_pair = r_result['Variable pair']
    corr = float(r_result['Pearson correlation coefficient'])
    pval = float(r_result['p-value'])
    assert var_pair == r_var_pair
    assert math.isclose(corr, r_corr, rel_tol=0, abs_tol=1e-06)
    assert math.isclose(pval, r_pval, rel_tol=0, abs_tol=1e-06)
