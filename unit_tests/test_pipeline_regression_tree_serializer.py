import requests
import json
import logging

# Required datasets: adni

endpointUrl='http://88.197.53.100:9090'


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
                    "value": "adni"
                },
                {
                    "name": "filter",
                    "value": ""
                }
            ]
    
    headers = {'Content-type': 'application/json', "Accept": "text/plain"}
    result = requests.post(endpointUrl+'/mining/query/PIPELINE_ISOUP_REGRESSION_TREE_SERIALIZER',data=json.dumps(data),headers=headers)
        
    """
    Results from exareme:
    
    "var nodes=[]; var edges=[]; nodes.push({id: 0, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 1, label: 'av45 <= 0.923707', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 2, label: '78.11', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 3, label: 'av45 <= 0.924682', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 4, label: '79.00', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 5, label: '73.73', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 6, label: 'apoe4 <= 1.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 7, label: '73.57', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 8, label: '71.39', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); edges.push({from: 1, to: 2, label: 'Yes', font: {align: 'top'}}); edges.push({from: 3, to: 4, label: 'Yes', font: {align: 'top'}}); edges.push({from: 3, to: 5, label: 'No', font: {align: 'top'}}); edges.push({from: 1, to: 3, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 1, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 7, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 8, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 6, label: 'No', font: {align: 'top'}}); var container = document.getElementById('visualization');var data = {  nodes: nodes,  edges: edges}; var options={                 layout: {                     hierarchical: {                         direction: 'UD',                         sortMethod: 'directed',                         levelSeparation: 155,                         nodeSpacing: 340,                         edgeMinimization: false                     }                 },                 edges: {                     arrows: {                         to: {                             enabled: true                         }                     }                 },                 interaction: {                     dragNodes: true                 },                 physics: {                     enabled: false                 }             }; network = new vis.Network(container, data, options);"
    
    """
    
    assert result.text == "var nodes=[]; var edges=[]; nodes.push({id: 0, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 1, label: 'av45 <= 0.923707', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 2, label: '78.11', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 3, label: 'av45 <= 0.924682', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 4, label: '79.00', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 5, label: '73.73', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 6, label: 'apoe4 <= 1.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 7, label: '73.57', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 8, label: '71.39', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); edges.push({from: 1, to: 2, label: 'Yes', font: {align: 'top'}}); edges.push({from: 3, to: 4, label: 'Yes', font: {align: 'top'}}); edges.push({from: 3, to: 5, label: 'No', font: {align: 'top'}}); edges.push({from: 1, to: 3, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 1, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 7, label: 'Yes', font: {align: 'top'}}); edges.push({from: 6, to: 8, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 6, label: 'No', font: {align: 'top'}}); var container = document.getElementById('visualization');var data = {  nodes: nodes,  edges: edges}; var options={                 layout: {                     hierarchical: {                         direction: 'UD',                         sortMethod: 'directed',                         levelSeparation: 155,                         nodeSpacing: 340,                         edgeMinimization: false                     }                 },                 edges: {                     arrows: {                         to: {                             enabled: true                         }                     }                 },                 interaction: {                     dragNodes: true                 },                 physics: {                     enabled: false                 }             }; network = new vis.Network(container, data, options);"