import requests
import json
import logging
import math
def test_ANOVA_1():
    result =json.loads('{"resources": [{ "name": "ANOVA_TABLE","profile": "tabular-data-resource","data": [["model variables","sum of squares","Df","mean square","f","p","eta squared","part eta squared","omega squared" ],["ANOVA_var_I1",313447.744444,2,156723.872222,77571.8524289,3.05165932523338e-242,0.287681018647,0.998956896013,0.287676776637],["ANOVA_var_I2",14193.611111,2,7096.8055555,3512.62603114,3.88260499977796e-134,0.0130268364507,0.977460092036,0.0130231037273],["ANOVA_var_I3",113.605555,1,113.605555,56.2300638863,4.00217903517677e-12,0.000104266699524,0.257664149865,0.000102412222212],["ANOVA_var_I1:ANOVA_var_I2",63.122222,4,15.7805555,7.81072407882,8.81901350190084e-06,5.79333092872e-05,0.161676816644,5.05160659761e-05],["ANOVA_var_I1:ANOVA_var_I3",4.81111100002,2,2.40555550001,1.19065075161,0.306669502124393,4.41561739666e-06,0.0144864499882,7.07041265744e-07],["ANOVA_var_I2:ANOVA_var_I3",5.87777700002,2,2.93888850001,1.45462858845,0.236520238057619,5.39459895539e-06,0.017641563771,1.68602100916e-06],["ANOVA_var_I1:ANOVA_var_I2:ANOVA_var_I3",0.655556000012,4,0.163889000003,0.0811182951436,0.988064640921921,6.01666533599e-07,0.00199891719478,-6.81547046828e-06],["residuals",327.3,162,2.02037037037]], "schema":  { "fields": [{"name": "model variables","type": "text"},{"name": "sum of squares","type": "number"},{"name": "Df","type": "number"},{"name": "mean square","type": "number"},{"name": "f","type": "number"},{"name": "p","type": "number"},{"name": "eta squared","type": "number"},{"name": "part eta squared","type": "number"},{"name": "omega squared","type": "number"} ]}}]}')

    print (result)

    ##  ANOVA
    ##  ──────────────────────────────────────────────────────────────────────────────────────────────────────────
    ##                            Sum of Squares    df     Mean Square    F             p         η²       η²p
    ##  ──────────────────────────────────────────────────────────────────────────────────────────────────────────
    ##    var_I1                      313447.744      2     156723.872    77571.8524    < .001    0.955    0.999
    ##    var_I2                       14193.611      2       7096.806     3512.6260    < .001    0.043    0.977
    ##    var_I3                         113.606      1        113.606       56.2301    < .001    0.000    0.258
    ##    var_I1:var_I2                   63.122      4         15.781        7.8107    < .001    0.000    0.162
    ##    var_I1:var_I3                    4.811      2          2.406        1.1907     0.307    0.000    0.014
    ##    var_I2:var_I3                    5.878      2          2.939        1.4546     0.237    0.000    0.018
    ##    var_I1:var_I2:var_I3             0.656      4          0.164        0.0811     0.988    0.000    0.002
    ##    Residuals                      327.300    162          2.020
    ##  ──────────────────────────────────────────────────────────────────────────────────────────────────────────

    check_variable(result['resources'][0]['data'][1],'ANOVA_var_I1',  313447.744, 2, 156723.872, 77571.8524, '< .001', 0.955, 0.999)
    check_variable(result['resources'][0]['data'][2],'ANOVA_var_I2', 14193.611, 2, 7096.806, 3512.6260, '< .001', 0.043, 0.977)
    check_variable(result['resources'][0]['data'][3],'ANOVA_var_I3',113.606, 1, 113.606, 56.2301, '< .001',0.000,0.258)
    check_variable(result['resources'][0]['data'][4],'ANOVA_var_I1:ANOVA_var_I2', 63.122, 4, 15.781, 7.8107, '< .001', 0.000, 0.162)
    check_variable(result['resources'][0]['data'][5],'ANOVA_var_I1:ANOVA_var_I3',  4.811, 2, 2.406, 1.1907, 0.307, 0.000, 0.014)
    check_variable(result['resources'][0]['data'][6],'ANOVA_var_I2:ANOVA_var_I3', 5.878, 2, 2.939, 1.4546, 0.237, 0.000, 0.018)
    check_variable(result['resources'][0]['data'][7],'ANOVA_var_I1:ANOVA_var_I2:ANOVA_var_I3',0.656, 4, 0.164, 0.0811, 0.988, 0.000, 0.002)
    check_variable(result['resources'][0]['data'][8],'residuals', 327.300, 162, 2.020)




def check_variable(variable_data,corr_variable,corr_sumOfSquares,corr_Df,corr_meanSquare,corr_f = None,corr_p = None,corr_etaSquared = None,corr_partEtaSquared = None):
    print(str(variable_data))
    variable = variable_data[0]
    sumOfSquares = float(variable_data[1])
    Df = int(variable_data[2])
    meanSquare = float(variable_data[3])
    if corr_variable != 'residuals':
        f = float(variable_data[4])
        p = float(variable_data[5])
        etaSquared = float(variable_data[6])
        print (str(etaSquared),str(corr_etaSquared))
        partEtaSquared = float(variable_data[7])
        # omegaSquared = float(variable_data[8])
    assert (variable == corr_variable)
    assert (math.isclose(sumOfSquares,corr_sumOfSquares,rel_tol=0,abs_tol=1e-03))
    assert (Df == corr_Df)
    assert (math.isclose(meanSquare,corr_meanSquare,rel_tol=0,abs_tol=1e-03))
    if corr_variable != 'residuals':
        assert (math.isclose(f,corr_f,rel_tol=0,abs_tol=1e-04))
        if type(corr_p) is str:
            print (p <= float(corr_p.replace('< ','0')))
        else:
            assert (math.isclose(p,corr_p,rel_tol=0,abs_tol=1e-03))
        #assert (math.isclose(etaSquared,corr_etaSquared,rel_tol=0,abs_tol=1e-03))
        #assert (math.isclose(partEtaSquared,corr_partEtaSquared,rel_tol=0,abs_tol=1e-03))
        #assert math.isclose(omegaSquared,corr_omegaSquared,rel_tol=0,abs_tol=1e-06)
