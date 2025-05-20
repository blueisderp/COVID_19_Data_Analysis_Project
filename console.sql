SELECT * FROM coviddeaths
ORDER BY 3, 4;

SELECT * FROM covidvaccinations
ORDER BY 3, 4;

--Select data  that we will be using
SELECT location, date, total_cases, new_cases, total_cases, population
FROM coviddeaths
ORDER BY 1, 2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / total_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE location like '%States%'
ORDER BY location, date;

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (CAST(total_cases AS float) / population) * 100 AS infection_percentage
FROM coviddeaths
WHERE location like '%States%'
ORDER BY location, date;

-- Looking at countries with highest infection rate compared to population
SELECT location,
       population,
       MAX(total_cases) AS highest_infection_count,
       MAX(CAST(total_cases AS float) / population) * 100 AS percentPopulationInfected
FROM coviddeaths
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY percentPopulationInfected DESC;

-- Looking at continents with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(CAST(total_cases AS float) / population) * 100 AS percentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY location, population
ORDER BY percentPopulationInfected DESC;

-- Showing countries with the highest death count per population
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


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths, ROUND(SUM(CAST(new_deaths AS numeric)) / SUM(new_cases) * 100, 2) AS  global_death_rate
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Rolling count of vaccinations by country
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_count
FROM coviddeaths d
INNER JOIN public.covidvaccinations v on d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

-- USING CTEs

WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, rolling_count) AS (
    SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_count
    FROM coviddeaths d
    INNER JOIN public.covidvaccinations v on d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
    ORDER BY 2, 3
)

-- Percent of country population vaccinated
SELECT *, (CAST(rolling_count AS float) / population) * 100 AS percent_of_population
FROM Pop_vs_Vac;

-- USING TEMP TABLE

DROP TABLE IF EXISTS percentpopulationvaccinated;
CREATE TEMPORARY TABLE percentpopulationvaccinated (
    Continent varchar(255),
    Location varchar(255),
    Date date,
    Population numeric,
    New_vaccinations numeric,
    rolling_num_vaccinated numeric
);

INSERT INTO percentpopulationvaccinated
SELECT d.continent, d.location, CAST(d.date AS date),
       d.population, CAST(v.new_vaccinations AS numeric), SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.date)
FROM coviddeaths d
INNER JOIN public.covidvaccinations v on d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

SELECT * FROM percentpopulationvaccinated; --Show Temp Table

SELECT *, (CAST(rolling_num_vaccinated AS float) / population) * 100 AS percent_of_population
FROM percentpopulationvaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW percentpopulationvaccinated AS
    SELECT d.continent, d.location, CAST(d.date AS date),
       d.population, CAST(v.new_vaccinations AS numeric), SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.date)
    FROM coviddeaths d
    INNER JOIN public.covidvaccinations v on d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
    ORDER BY 2,3;