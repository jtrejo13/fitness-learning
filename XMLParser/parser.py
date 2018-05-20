# parser.py --- 
# 
# Filename: parser.py
# Description: 
#            Parser class for loading and extracting data
# Author:    Yu Lu
# Email:     yulu@utexas.edu
# Github:    https://github.com/SuperYuLu 
# 
# Created: Sun May 20 13:16:00 2018 (-0500)
# Version: 
# Last-Updated: Sun May 20 13:48:55 2018 (-0500)
#           By: yulu
#     Update #: 24
# 
import numpy as np 
import pandas as pd 
#import matplotlib.pyplot as plt
import xml.etree.ElementTree as ET


class Parser:
    factors = {
        'ActiveEnergyBurned':'HKQuantityTypeIdentifierActiveEnergyBurned' ,
        'BasalEnergyBurned': 'HKQuantityTypeIdentifierBasalEnergyBurned',
        'DistanceWalkingRunning': 'HKQuantityTypeIdentifierDistanceWalkingRunning',
        'HeartRate':'HKQuantityTypeIdentifierHeartRate',
        'StepCount': 'HKQuantityTypeIdentifierStepCount',
    }
    
    def __init__(self, fileName, startDate):
        self.fileName = fileName
        self.treeroot = Parser._gen_element_tree_root(fileName)
        self.startDate = startDate
    
    @staticmethod
    def _gen_element_tree_root(fileName):
        tree = ET.parse(fileName)
        tree_root =  tree.getroot()
        return tree_root

    @property
    def listTypes(self):
        types = []
        for r in self.treeroot.findall('Record'):
            date = r.attrib['startDate'][:10]
            if date == self.startDate:
                type = r.attrib['type']
                types.append(type)
                return(np.unique(types))


    def loadTypeData(root, typeName):
        startTime, endTime, units, values = [], [], [], []
        factors = self.factors
        for r in self.tree_root.findall('Record'):
            startDate = r.attrib['startDate']
            endDate = r.attrib['endDate']
            date = startDate[:10]
            if date == self.startDate and r.attrib['type'] == factors[typeName]:
                unit = r.attrib['unit']
                value = r.attrib['value']
                startTime.append(startDate)
                endTime.append(endDate)
                values.append(value)
                units.append(unit)
            else:
                pass
        labels = ['StartTime', 'EndTime', typeName, 'units']
        tempData = pd.DataFrame(dict(zip(labels, [startTime, endTime, values, units])))
        data = tempData.copy()
        data.iloc[:,0] = tempData.StartTime.astype(str).str[:-6] #strip out time zone 
        data.iloc[:,1] = tempData.EndTime.astype(str).str[:-6]
        data.iloc[:,2] = tempData[typeName]
        data.iloc[:,3] = tempData['units']
        data.columns = labels
        return data
            
    def loadWorkOut(root):
        startTimes, endTimes, duration, durationUnit, activityType = [], [], [], [], []
        for r in self.tree_root.findall('Workout'):
            startTime = r.attrib['startDate']
            endTime = r.attrib['endDate']
            if startTime[:10] == self.startDate:
                duration.append(r.attrib['duration'])
                durationUnit.append(r.attrib['durationUnit'])
                acttype = r.attrib['workoutActivityType'][21:]
            else:
                pass
            # Correct wrong logging
            # if acttype == 'StairClimbing':
            #         acttype = 'Elliptical'
            # elif acttype == 'Yoga':
            #     acttype = 'TraditionalStrengthTraining'
            # elif acttype == 'Bowling':
            #     acttype ='Walking'
            # else:
            #     pass
            activityType.append(acttype)
            startTimes.append(startTime)
            endTimes.append(endTime)
    labels = ['StartTime', 'EndTime', 'Duration', 'ActivityType']
    data = pd.DataFrame(dict(list(zip(labels, [startTimes, endTimes, duration, activityType]))))
    data.StartTime = data.StartTime.astype(str).str[:-6]
    data.EndTime = data.EndTime.astype(str).str[:-6]
    return data
