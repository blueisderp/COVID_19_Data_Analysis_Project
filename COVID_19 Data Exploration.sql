/*
    Data Exploration on Covid-19 Global Statistics Reported 2020-2021
    By: Le Duong

    Utilizing Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Converting Data Types

    Credit to Our World in Data for the datasets used: https://ourworldindata.org/covid-deaths
*/

-- Raw datasets used
SELECT *
FROM coviddeaths
ORDER BY location, date;

SELECT *
FROM covidvaccinations
ORDER BY location, date;


--Total Cases vs Total Deaths by date
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / total_cases) * 100.0 AS death_percentage
    --need to cast one of the operands as a float to get a decimal value for death_percentage ^
FROM coviddeaths
WHERE location LIKE '%States%' --Set to US, search for desired country here
ORDER BY location, date;


--Total Cases vs Population by date
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (CAST(total_cases AS float) / population) * 100.0 AS infection_percentage
        --need to cast one of the operands as a float to get a decimal value for death_percentage ^
FROM coviddeaths
WHERE location LIKE '%States%' --Set to US, search for desired country here
ORDER BY location, date;


-- Looking at countries with the highest infection rate compared to population
SELECT location,
       population,
       MAX(total_cases) AS highest_infection_count,
        --need to convert total_cases into a numeric type to use the round function since it's an integer type
       ROUND(MAX(CAST(total_cases AS NUMERIC) / population) * 100, 2) AS percentPopulationInfected
FROM coviddeaths
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY percentPopulationInfected DESC;

-- Looking at continents with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(CAST(total_cases AS float) / population) * 100 AS percentPopulationInfected
FROM coviddeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International') --removing non-continents
GROUP BY location, population
ORDER BY percentPopulationInfected DESC;

-- Showing countries with the highest death count
SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL and total_deaths IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Showing continents with the highest death count per population
-- when location is a continent, continent column is NULL
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Global Numbers (cases, deaths, death percentage) using 'World' as location
SELECT SUM(new_cases) AS global_cases,
       SUM(cast(new_deaths AS INT)) AS global_deaths, ROUND(SUM(cast(new_deaths AS NUMERIC)) / SUM(New_Cases) * 100.0, 2) AS global_death_rate
FROM CovidDeaths
WHERE location = 'World'
ORDER BY 1,2;

--Global Numbers by summing all new cases/deaths from all countries (slightly off from previous query)
SELECT SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths, ROUND(SUM(CAST(new_deaths AS numeric)) / SUM(new_cases) * 100.0, 2) AS  global_death_rate
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

--by dates
SELECT date, SUM(new_cases) as global_cases, SUM(cast(new_deaths as INT)) as global_deaths,
       ROUND(SUM(CAST(new_deaths AS NUMERIC)) / SUM(New_Cases) * 100.0, 2) AS global_death_rate
FROM CovidDeaths
WHERE location = 'World'
GROUP BY date
ORDER BY 1,2;

SELECT date, SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths,
       ROUND(SUM(CAST(new_deaths AS NUMERIC)) / SUM(new_cases) * 100.0, 2) AS  global_death_rate
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Rolling count of vaccinations by country
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_num_vaccinated
FROM coviddeaths d
INNER JOIN public.covidvaccinations v on d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTEs

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_num_vaccinated) AS (
    SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.date)
    FROM coviddeaths d
    INNER JOIN public.covidvaccinations v on d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
    ORDER BY 2, 3
)

-- Percent of country population vaccinated
SELECT *, (CAST(rolling_num_vaccinated AS float) / population) * 100 AS percent_of_population
FROM pop_vs_vac;

-- Using Temp Table

DROP TABLE IF EXISTS percentpopulationvaccinated; --in case edits need to be made

CREATE TEMPORARY TABLE percentpopulationvaccinated (
    --define fields
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATE,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    rolling_num_vaccinated NUMERIC
);

INSERT INTO percentpopulationvaccinated
    SELECT d.continent, d.location, CAST(d.date AS DATE),
           d.population, CAST(v.new_vaccinations AS NUMERIC), SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.date)
    FROM coviddeaths d
    INNER JOIN public.covidvaccinations v on d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
    ORDER BY 2,3;

SELECT * FROM percentpopulationvaccinated; --Show Temp Table

SELECT *, (CAST(rolling_num_vaccinated AS float) / population) * 100 AS percent_of_population
FROM percentpopulationvaccinated;





