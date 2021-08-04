# 1A
Analysis of IBBIS 1A (post-trial)

This repo tracks the analysis of the IBBIS 1A evaluation. It also documents the steps taken in the process of analysing the data. Changes and decisions made can be inspected for each file/folder by going through the version history.

A statistical analysis plan has been finalized and registrered before engaging in analysis. The code provided here shows the complete pipeline from raw data to final results.

Complete scripts are in ./lib. Log files as specified in 1A.R are in ./log. Output results are in ./out.

Major changes made in relation to the statistical analysis plan are logged below:

### 2021-08-04:
  - as some variables are not available, educational level, diagnoses and recent hospital treatments are not used for propensity score matching. 
  - branch codes and income transfer categories are used as propensity score matching factors in order to capture the socioeconomic status and previous work experience. 
