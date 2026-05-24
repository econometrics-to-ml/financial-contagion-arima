# Automated ARIMA/Box-Jenkins Time Series Pipeline

*A large-scale automated ETL and analytics system for time series modeling*

## Overview

This project implements a fully automated, end-to-end ETL pipeline for fitting ARIMA (Box-Jenkins) models to **thousands of time series**. The system performs the complete data workflow: from data ingestion and quality checks (stationarity testing) to transformation (differencing), analytical modeling, and exporting results to structured formats. The code was developed as part of a research project on financial contagion effects across different markets — the core of my doctoral dissertation.

The pipeline automatically:
- Ingests panel data from raw sources (.dta files)
- Tests for stationarity (data quality checks) using the **Breusch-Godfrey test** and **Phillips-Perron test**
- Handles non-stationary series through **differencing** (up to 3rd order) and **trend extraction**
- Selects optimal ARMA(p,q) lag orders using the **AIC criterion**
- Estimates ARIMA models for each time series
- Exports structured results (model residuals, selected lags) to XML format for downstream analysis

## Key Features

- **Scale:** Processes thousands of variables across multiple years (2008–2016)
- **Automation:** Fully automated data workflow — no manual intervention required
- **Robustness:** Handles edge cases (collinearity, zero variance) and excludes problematic series
- **Runtime:** Approximately 24 hours of continuous computation on the full dataset
- **Data Quality:** Built-in validation at every stage: stationarity checks, trend extraction, post-model diagnostics

## Technical Details

- **Language:** Stata
- **Key Methods:** ARIMA, Box-Jenkins, Phillips-Perron test, Breusch-Godfrey test, AIC lag selection
- **Data:** Panel data with thousands of time series variables
- **Output:** Model residuals stored in new variables; lag orders exported to XML for integration with reporting pipelines

## Why This Matters

This project demonstrates production-relevant data engineering skills:
- **ETL Pipeline Design:** Full data lifecycle: extract → validate → transform → model → export
- **Large-Scale Data Processing:** Handling thousands of variables in a single automated workflow
- **Data Quality Assurance:** Multi-stage statistical validation of input data
- **Scalable Architecture:** Loop-based processing that can be parallelized (MapReduce-ready logic)
- **Production Mindset:** Robust error handling, automatic exclusion of unusable data

Out of thousands of time series tested, only a small subset satisfied the criteria for forecasting — demonstrating the rigor of the selection process.

## Status

This project is presented as a portfolio piece. The original dataset is proprietary and not included. The code is shown to demonstrate methodology, programming skills, and the scale of the work.

## Author

Ekaterina — Data Scientist & Researcher

[GitHub Profile](https://github.com/econometrics-to-ml)
