# Fitness Learning  
----  
A light weight apple watch app with real time recognition of workout categories with pretrained machine learning algorithm. 

## Motivation  
While apple watch provide fitness data monitoring and analysis, it relies on users to manually input the workout category to track. It'll be much more user-friendly if apple watch could automatically detect and categorize the type of workout in the real time. 

## Data  
Data was collected directly from the Apple Watch and with the assitance of a third party application called PowerSense. The data included accelerometer measurements, heart rate and calorie count


## Feature selection  
We first looked in the the data directly exported from apple watch program, which include heart rate, calorie count, etc. The raw data was in XML file format and has many sub-categories. WE set up python notebooks to extract the data we want, clean the data and reformat it into different CSV files by using pands. Then we looked in to heart rate and calories for different workouts, trying to decide whether we will using it as our feature for later model training using machine algorithm. 

As can be seen for the juypter notebook for analysis, the data was very noisy and, most importantly, has poor time resolution ( ~ 1 min per measuremnet) . From here we decide not using heart rate and calorie count as the features, but using the accelerometer measurements data, which can give us very high measurement resolution (50Hz sampling rate, every 0.02s per measurement). 
