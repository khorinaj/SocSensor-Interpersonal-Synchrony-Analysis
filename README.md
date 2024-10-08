# SocSensor-Interpersonal-Synchrony-Analysis
# Time Series Similarity Analysis, Classification, and Visualization

This project consists of four main MATLAB scripts for analyzing time series data, particularly focused on acceleration/gyroscope signal data. It includes data preparation, signal processing, feature analysis, classification of interaction levels, and visualization of results for SocSensor dataset.
It also includes the simulated example for generating two simulated siganls and testing the similairty analysis on more controlled controlled envieroment.

## Author
Yanke Sun

## Date
19/08/2024

## About SocSensor dataset
The SocSensor dataset encompasses synchronized acceleration and gyroscope data collected at 25Hz, from wrist-worn mBient sensors for three distinct groups of children (young ASC, older ASC, and neurotypical) and adult participants (teachers, teaching assistants, and researchers) 
across various real-world educational settings. This rich dataset provides a comprehensive view of interpersonal interactions during structured activities like drama lessons and party games over eight different days of data collection.

## Project Structure
1. `SimilarityAnalysis_1.m`: Main script for similarity analysis
2. `FeatureAnalysis_2.m`: Script for analysis Rsquare and pvalues from linear regression for different similarity measures
3. `Classification_3.m`: Script for interaction level classification
4. `Visualization_4.m`: Script for generating visualizations of interaction patterns
5. `SimulatedDataExample.m`: Script for generating two simulated signals and apply similarity analysis
- `src/`: Directory containing functions
- `Info/`: Directory containing session information
- `Data/`: Directory for storing raw data (Data.mat) 
- `Analysis/`: Directory where processed data is saved and loaded from

## Prerequisites

- MATLAB (version used for development: R2023a)
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox (for model evaluation and classification)

## Data Preparation

Raw data file called `Data.mat` storing synchronized acceleration and gyroscope data needs to be downloaded from the OSF link: https://osf.io/498up/?view_only=f57a9915ce86429d885e901db98fae13 and saved in the `Data` folder of this project.

## Usage

1. Ensure all prerequisites are installed and the raw data file is in place.
2. Open MATLAB and navigate to the project directory.
3.(Optional) Run the simulated data example for getting familiar of different similarity analysis
4. Run the main scripts for SocSensor dataset
   First-time run: follows the order SimilarityAnalysis_1.m->FeatureAnalysis_2.m->Classification_3.m->Visualization_4.m
   Save all variable

## Script Descriptions

### 1. SimilarityAnalysis_1.m
- Data preparation
- Wavelet Analysis
- Windowed Cross-Correlation Analysis
- Windowed Dynamic Time Warping Analysis

### 2. FeatureAnalysis_2.m
- Extracts algorithm values from selected time points
- Calculates R-square values for individual algorithms
- Generates R-square values for combined features

### 3. Classification_3.m

- Loads processed data and extracted features
- Configures and trains classification models (Ensemble Bagged Tree or Random Forest)
- Evaluates model performance

### 4. Visualization_4.m

- Use classification to generate threshold (high and low interactions) to be used in visualisation plots
- Generates Tiger Plots for specific participants
- Creates Network Plots to visualize interaction patterns
- Produces overall interaction heatmaps

### 5. SimulatedDataExample.m
-Serves as a controlled environment for testing and validating analysis methods
-Generates two stimulated signals with varying levels of synchronization
-Performs various similarity analyses on the simulated data
-Visualizes the original simulated data and the results from different analyses


## Citation

