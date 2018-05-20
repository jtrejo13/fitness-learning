# Fitness Learning
----
## Table of Contents
- [About](#about)
- [Data](#data)
- [Logistic Classifier](#logistic-classifier)
- [Watch App](#watch-app)
- [Running the App](#running-the-app)
- [Tools](#tools)
- [Authors](#authors)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## About  
A light weight apple watch app with real time recognition of workout categories with pretrained machine learning algorithm.

## Motivation  
While apple watch provide fitness data monitoring and analysis, it relies on users to manually input the workout category to track. It'll be much more user-friendly if apple watch could automatically detect and categorize the type of workout in the real time.

## Data Acquisition  

### PowerSense
Data was collected directly from the Apple Watch and with the assitance of a third party application called [PowerSense](https://itunes.apple.com/us/app/powersense-motion-sensor-data-logging-tool/id1050491381?mt=8),which is a free app on apple stores and the main reason we use it is that it provide high sampling rate of data collection. According to the App store description:  

> PowerSense is a powerful motion sensor logging tool that can track and record various sensor data on your iPhone and Apple Watch. These sensors include accelerometer, gyroscope, magnetometer, etc. The recorded data is stored as XML/csv files and can be then sent out via email, AirDrop to your Mac or upload to your linked Dropbox account.  

In our purpose of training the ML model, we use XML file as saved by the *PowerSense* app, since that gives more information.

### Export your own training data  
Although not required, you may want to train the model by using your own workout data. Here is how:
**To be added** *Describe how to use PowerSense to get export the data we want*  

You can configure the sampling rate to be from 1 to 100 Hz for phone. 50 Hz is fixed for watch.

### XML Data Parser

- Included data types:  
  + Accelerometer measurements
  + Heart rate
  + Calorie count

- Data format
  + XML element tree

## Feature selection  
We first looked in the the data directly exported from apple watch program, which include heart rate, calorie count, etc. The raw data was in XML file format and has many sub-categories. WE set up python notebooks to extract the data we want, clean the data and reformat it into different CSV files by using pands. Then we looked in to heart rate and calories for different workouts, trying to decide whether we will using it as our feature for later model training using machine algorithm.   

As can be seen for the juypter notebook for analysis, the data was very noisy and, most importantly, has poor time resolution ( ~ 1 min per measuremnet) . From here we decide not using heart rate and calorie count as the features, but using the accelerometer measurements data, which can give us very high measurement resolution (50Hz sampling rate, every 0.02s per measurement).   

## Logistic Classifier

A Logistic Regression classifier was trained and tested using the accelerometer data collected to predict the type of activity being performed by the user. The classifier was built in MATLAB and is composed of the following files:

* **logistic.m**: The main script. Process data, trains and tests a logistic regression model, and outputs a coefficients matrix.

* **dataprocess.m**: A script that compiles accelerometer data from the .csv files found in \\data and splits it into an `nxm` matrix of features, called X, and an `nx1` labels matrix, Y. The matrices are also shuffled before being exported into their corresponding .mat file.

* **splitData.m**: A function to split matrices X and Y into a training set and a test set, based on the passed 'training ratio'.

* **oneVsAll.m**: Function trains multiple logistic regression classifiers and returns all the classifiers in a matrix all_theta, where the i-th row of all_theta corresponds to the classifier for label i.

* **predictOneVsAll.m**: Predict the label for a trained one-vs-all classifier. The labels are in the range 1..K, where `K = size(all_theta, 1)`

* **fmincg.m**: Function that allows us to find the minimum point in our cost function.

* **lrCostFunction.m**: Computes the cost and gradient for logistic regression with
regularization.

* **sigmod.m**: Evaluates the sigmoid function at a given point.

### Features and Labels

For our model, we used 13 features, which are the [raw accelerometer events](https://developer.apple.com/documentation/coremotion/getting_raw_accelerometer_events) logged by the Apple Watch:
  - attitude_roll [radians]
  - attitude_pitch [radians]
  -	attitude_yaw [radians]
  -	rotation_rate (x, y, z)[radians/s]
  -	gravity (x, y, z)[G],
  - user_acc (x, y, z)[G]

Our data consisted of 4 types of activity: rowing, elliptical, push ups, and treadmill, so our outcome labels were classified as follows:
  - Elliptical=1, Pushups=2, Rowing=3, Treadmill=4

### Accuracy

After splitting the input data into a 70% Training and 30% Test data, our classifier achieved an accuracy of **94.12%**

## Apple watch app dev   

## Real time testing

## Tools

This project made use of the following tools:

* **Apple Watch Development**
  - Xcode
  - Swift

* Data Parsing
  - Python
  - Jupyter
  - Matplotlib
  - NumPy

* Logistic Classifier
  - MATLAB

## Authors

* **Carlos Trejo**
  - [GitHub](https://github.com/cdt876)
  - [LinkedIn](https://www.linkedin.com/in/carlostrejomtz/)
  - [Home](https://cdt876.github.io)

* **Juan Trejo**
  - [GitHub](https://github.com/jtrejo13)
  - [LinkedIn](https://www.linkedin.com/in/jtrejo13/)
  - [Home](https://jtrejo13.github.io/)

* **Yu Lu**
  - [GitHub](https://github.com/SuperYuLu)
  - [LinkedIn](https://www.linkedin.com/in/yu-lu-12b123a6/)
  - [Home](https://superyulu.github.io/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgements
* [PowerSense](https://itunes.apple.com/us/app/powersense-motion-sensor-data-logging-tool/id1050491381?mt=8) to collect raw accelerometer vents from the Apple Watch
* [Eric Hsiao](https://github.com/hsiaoer) for providing a [template](https://github.com/hsiaoer/MotionTracking) that served as the base for our Apple Watch app
