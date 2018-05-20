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
# Last-Updated: Sun May 20 14:32:11 2018 (-0500)
#           By: yulu
#     Update #: 44
# 
import numpy as np 
import pandas as pd 
import matplotlib.pyplot as plt
import xml.etree.ElementTree as ET


class Parser:
    """
    Class Parser
    -------------
    Read in XML file of watch workout data from *PowerSence* app, extract wanted work types
    and export as csv files or plot the result
    
    Input
    ------------
    fileName: filename (including path) to export xml file from apple watch app *PowerSense"
    startDate: Specify start date of the data wanted, format example: 2018-12-01
    
    Properties
    ------------
    * listTypes: list avaliable workout types recorded in the xml file 

    Methods
    ------------
    * loadWorkOutSummary: list summary report on the workout data in the xml file
    * loadTypeDate: load the data of specific type of workout and return a pandas dataframe
    * to_csv: save loaded data to csv 

    """

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
        """
        initialize xml elementary tree root obj
        """
        tree = ET.parse(fileName)
        tree_root =  tree.getroot()
        return tree_root

    @property
    def listTypes(self):
        """
        List avaliable work out type data in the xml file
        """
        types = []
        for r in self.treeroot.findall('Record'):
            date = r.attrib['startDate'][:10]
            if date == self.startDate:
                type = r.attrib['type']
                types.append(type)
                return(np.unique(types))


    def loadTypeData(self, typeName, plot = False, as_csv = False):
        """
        load data for specifice type of workout
        """
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

        if plot: Parser._plot_workout(datta, typeName)
        if as_csv: Parser.to_csv(data, self.fileName.split('.')[0]  + typeName + '.csv')
        
        return data
            
    def loadWorkOutSummary(self):
        """
        Generate a summary report on the workout, including workout type, starting time 
        stop time, etc
        """
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

    @staticmethod
    def to_csv(data, fileName):
        """
        save as csv
        """
        if type(data) == pd.core.frame.DataFrame:
            data.to_csv(fileName, index = False)
        else:
            raise TypeError("Data has to be type pandas DataFrame")
        
    @staticmehtod
    def _plot_workout(dataframe, typeName):
        """
        plot single workout data
        """
        dataframe.StartTime = pd.to_datetime(dataframe.StartTime)
        dataframe.EndTime = pd.to_datetime(dataframe.EndTime)
        dataframe.plot(y = typeName, x = 'StartTime')

    
