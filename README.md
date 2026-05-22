# Automated ARIMA/Box-Jenkins Time Series Pipeline

*A large-scale automated system for time series modeling and forecasting*

## Overview

This project implements a fully automated pipeline for fitting ARIMA (Box-Jenkins) models to **thousands of time series**. The code was developed as part of a research project on financial contagion effects across different markets — the core of my doctoral dissertation.

The pipeline automatically:
- Tests for stationarity using the **Breusch-Godfrey test** and **Phillips-Perron test**
- Handles non-stationary series through **differencing** (up to 3rd order) and **trend extraction**
- Selects optimal ARMA(p,q) lag orders using the **AIC criterion**
- Estimates ARIMA models for each time series
- Exports results to XML for further analysis

## Key Features

- **Scale:** Processes thousands of variables across multiple years (2008–2016)
- **Automation:** No manual intervention required — the code loops through all variables and applies the appropriate transformation
- **Robustness:** Handles edge cases (collinearity, zero variance after differencing) and excludes problematic series
- **Runtime:** Approximately 24 hours of continuous computation on the full dataset

## Technical Details

- **Language:** Stata
- **Key Methods:** ARIMA, Box-Jenkins, Phillips-Perron test, Breusch-Godfrey test, AIC lag selection
- **Data:** Panel data with thousands of time series variables
- **Output:** Model residuals stored in new variables; lag orders exported to XML

## Why This Matters

This project demonstrates:
- Experience with **large-scale data processing** and automation
- Deep understanding of **time series analysis** and **statistical testing**
- Ability to design and implement **end-to-end analytical pipelines**
- Skill in handling **edge cases** and ensuring code robustness

Out of thousands of time series tested, only a small subset satisfied the criteria for forecasting — demonstrating the rigor of the selection process.

## Status

This project is presented as a portfolio piece. The original dataset is proprietary and not included. The code is shown to demonstrate methodology, programming skills, and the scale of the work.

## Author

Ekaterina — Data Scientist & Researcher

[GitHub Profile](https://github.com/econometrics-to-ml)