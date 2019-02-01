import requests
import json
import logging



headers = {'Content-type': 'application/json', "Accept": "text/plain"}
url='http://prozac.madgik.di.uoa.gr:9090/mining/query/PIPELINE_ISOUP_MODEL_TREE_SERIALIZER'

def test_PIPELINE_MODEL_TREE_SERIALIZER_1():
    logging.info("---------- TEST : Pipeline Model Tree Serializer ADNI")

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
    
    "var nodes=[]; var edges=[]; nodes.push({id: 0, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 1, label: 'subjectageyears: apoe4 * NaN + av45 * NaN + NaN', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 2, label: 'apoe4 <= 1.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 3, label: 'subjectageyears: apoe4 * NaN + av45 * NaN + NaN', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 4, label: 'subjectageyears: apoe4 * NaN + av45 * NaN + NaN', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); edges.push({from: 0, to: 1, label: 'Yes', font: {align: 'top'}}); edges.push({from: 2, to: 3, label: 'Yes', font: {align: 'top'}}); edges.push({from: 2, to: 4, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 2, label: 'No', font: {align: 'top'}}); var container = document.getElementById('visualization');var data = {  nodes: nodes,  edges: edges}; var options={                 layout: {                     hierarchical: {                         direction: 'UD',                         sortMethod: 'directed',                         levelSeparation: 45,                         nodeSpacing: 340,                         edgeMinimization: false                     }                 },                 edges: {                     arrows: {                         to: {                             enabled: true                         }                     }                 },                 interaction: {                     dragNodes: true                 },                 physics: {                     enabled: false                 }             }; network = new vis.Network(container, data, options);"
    
    """
    
    assert result.text == "var nodes=[]; var edges=[]; nodes.push({id: 0, label: 'apoe4 <= 0.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 1, label: 'subjectageyears: apoe4 * NaN + av45 * NaN + NaN', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 2, label: 'apoe4 <= 1.0', color: 'orange', font: {'face': 'Monospace'}}); nodes.push({id: 3, label: 'subjectageyears: apoe4 * NaN + av45 * NaN + NaN', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); nodes.push({id: 4, label: 'subjectageyears: apoe4 * NaN + av45 * NaN + NaN', shape: 'box', font: {'face': 'Monospace', align: 'left'}}); edges.push({from: 0, to: 1, label: 'Yes', font: {align: 'top'}}); edges.push({from: 2, to: 3, label: 'Yes', font: {align: 'top'}}); edges.push({from: 2, to: 4, label: 'No', font: {align: 'top'}}); edges.push({from: 0, to: 2, label: 'No', font: {align: 'top'}}); var container = document.getElementById('visualization');var data = {  nodes: nodes,  edges: edges}; var options={                 layout: {                     hierarchical: {                         direction: 'UD',                         sortMethod: 'directed',                         levelSeparation: 45,                         nodeSpacing: 340,                         edgeMinimization: false                     }                 },                 edges: {                     arrows: {                         to: {                             enabled: true                         }                     }                 },                 interaction: {                     dragNodes: true                 },                 physics: {                     enabled: false                 }             }; network = new vis.Network(container, data, options);"