import requests
import json
import logging



headers = {'Content-type': 'application/json', "Accept": "text/plain"}
url='http://prozac.madgik.di.uoa.gr:9090/mining/query/PIPELINE_ISOUP_REGRESSION_TREE_SERIALIZER'

def test_PIPELINE_REGRESSION_TREE_SERIALIZER_1():
    logging.info("---------- TEST : Pipeline Regression Tree Serializer ADNI")

    data = [
                {
                    "name": "target_attributes",
                    "value": "subjectageyears"
                },
                {
                    "name": "descriptive_attributes",
                    "value": "apoe4,av45"
                },
                {
                    "name": "dataset",
                    "value": "adni,chuv_adni,epfl_adni"
                },
                {
                    "name": "filter",
                    "value": ""
                }
            ]
    result = requests.post(url,data=json.dumps(data),headers=headers)
        
    """
    Results from exareme:
    
    "var nodes=[]; var edges=[]; nodes.push({id: 0, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 1, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 2, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 3, label: '73.45', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 4, label: '74.95', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 5, label: '72.53', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 6, label: 'apoe4 <= 1.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 7, label: '73.66', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 8, label: '71.06', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); edges.push({from: 2, to: 3, label: 'Yes', font: {align: 'top'}}); edges.push({from: 2, to: 4, label: 'No', font: {align: 'top'}}); edges.push({from: 1, to: 2, label: 'Yes', font: {align: 'top'}}); edges.push({from: 1, to: 5, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 1, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 7, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 8, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 6, label: 'No', font: {align: 'top'}}); var container = document.getElementById('visualization');var data = {  nodes: nodes,  edges: edges}; var options={                 layout: {                     hierarchical: {                         direction: 'UD',                         sortMethod: 'directed',                         levelSeparation: 155,                         nodeSpacing: 340,                         edgeMinimization: false                     }                 },                 edges: {                     arrows: {                         to: {                             enabled: true                         }                     }                 },                 interaction: {                     dragNodes: true                 },                 physics: {                     enabled: false                 }             }; network = new vis.Network(container, data, options);"
    
    """
    
    assert result.text == "var nodes=[]; var edges=[]; nodes.push({id: 0, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 1, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 2, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 3, label: '73.45', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 4, label: '74.95', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 5, label: '72.53', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 6, label: 'apoe4 <= 1.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 7, label: '73.66', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 8, label: '71.06', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); edges.push({from: 2, to: 3, label: 'Yes', font: {align: 'top'}}); edges.push({from: 2, to: 4, label: 'No', font: {align: 'top'}}); edges.push({from: 1, to: 2, label: 'Yes', font: {align: 'top'}}); edges.push({from: 1, to: 5, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 1, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 7, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 8, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 6, label: 'No', font: {align: 'top'}}); var container = document.getElementById('visualization');var data = {  nodes: nodes,  edges: edges}; var options={                 layout: {                     hierarchical: {                         direction: 'UD',                         sortMethod: 'directed',                         levelSeparation: 155,                         nodeSpacing: 340,                         edgeMinimization: false                     }                 },                 edges: {                     arrows: {                         to: {                             enabled: true                         }                     }                 },                 interaction: {                     dragNodes: true                 },                 physics: {                     enabled: false                 }             }; network = new vis.Network(container, data, options);"