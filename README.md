# Analyzing COVID-19 Pandemic Data Trends with SQL

## Description
This project presents a comprehensive data analysis of reported information from the COVID-19 global pandemic (2020–2021), with the objective of identifying and illustrating key trends observed during both the onset and the subsequent decline of the outbreak. Using SQL, the analysis uncovers valuable insights into infection rates, death count, and vaccination coverage—examined by country, across broader regions, and globally. The analytical process culminates in a dynamic, user-friendly Power BI dashboard that enables users to see and interact with visualizations displaying our findings. The analytical process culminates in a dynamic, user-friendly Power BI dashboard that enables users to interact with visualizations and explore findings in an accessible and intuitive manner. This data-driven exploration facilitates a deeper understanding of regional and global responses to the pandemic and may serve to inform strategic decision-making by health officials and policymakers in the event of future public health crises.

## Data Analysis Workflow
The analysis was carried out through the following key steps:
  - Data Cleaning and Preparation: Large, raw datasets were cleaned and optimized using Excel to enhance processing efficiency and facilitate downstream data manipulation.
  - Data Extraction: Developing SQL queries to extract relevant data points and uncover significant trends across various geographies and timeframes.
  - Data Export and Integration: The resulting query outputs were exported as view tables, allowing seamless integration into the Power BI environment.
  - Data Transformation in Power BI: Using Power Query and DAX, the imported data was transformed to ensure consistency, accuracy, and clarity for presentation.
  - Interactive Visualization Design: Custom interactive visual elements—such as tables, charts, and maps—were developed to highlight crucial insights and patterns within the data. 
  - Dashboard Compilation and Interactivity: These visualizations were consolidated into a well-organized, cross-filtered Power BI dashboard, enabling users to interact with multiple components simultaneously and gain a holistic understanding of how different metrics interrelate.

## Techonologies
PostgreSQL (database and data manipulation), DataGrip (database IDE), Excel (data cleaning), Power Query (data cleaning/manipulation), DAX (data manipulation), Power BI (data visualization tool)

## Dataset:
Credit to the Our World in Data for the datasets used in this project which are available to the public here: https://ourworldindata.org/covid-deaths.

Please note the data used was taken from 2020-2021 (see [CovidDeaths.csv](Datasets/CovidDeaths.csv) and [CovidVaccinations.csv](DataSets/CovidVaccinations.csv)). 

## Dashboard
To access the dashboard, please download the [COVID_19_Dashboard.pbix](Data_Analysis/COVID_19_Dashboard.pbix) file and open it in Power BI Desktop. 

![COVID_19 Data Exploration.pbix](Dashboard.png)
