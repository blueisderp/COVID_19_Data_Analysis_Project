/*
    Creating Views used for later Visualization based on Covid-19 Global Statistics Reported 2020-2021
    By: Le Duong

    Utilizing Views, Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Converting Data Types

    Credit to Our World in Data for the datasets used: https://ourworldindata.org/covid-deaths
*/

-- 1.
CREATE VIEW global_death_percentage AS
    SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS FLOAT)) / SUM(New_Cases) * 100.0 AS DeathPercentage
    FROM CovidDeaths
    --continent column is null when location column is a continent (Europe, Africa, Asia, etc.)
    WHERE continent IS NOT NULL --removing continents so it won't count those numbers
    ORDER by 1,2;


-- 2.
CREATE VIEW death_count_by_continent AS
    -- Need to cast new_deaths as INT to use SUM function
    SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
    FROM CovidDeaths
    WHERE continent IS NULL
        AND location NOT IN ('World', 'European Union', 'International') --remove non-continents
    Group by location
    ORDER by TotalDeathCount DESC;


-- 3.
CREATE VIEW death_count_by_country AS
    -- Need to cast new_deaths as INT to use SUM function
    SELECT location, continent, CAST(SUM(new_deaths) AS INT) AS TotalDeathCount
    FROM coviddeaths
    --WHERE location like '%states%'
    WHERE continent IS NOT NULL
        AND new_deaths IS NOT NULL --weeding out countries who did not record any death numbers
        AND location NOT IN ('World', 'European Union', 'International')
    GROUP BY location, continent
    ORDER BY TotalDeathCount DESC;


-- 4.
CREATE VIEW PercentPopulationInfectedByCountry AS
    -- Need to cast total_cases as FLOAT for PercentPopulationInfected to be a decimal value
    SELECT Location, continent, Population, MAX(total_cases) AS HighestInfectionCount,  Max(CAST(total_cases AS FLOAT) / population) * 100.0 AS PercentPopulationInfected
    FROM CovidDeaths
    --WHERE location like '%states%'
    WHERE total_cases IS NOT NULL AND continent IS NOT NULL AND location not in ('World', 'European Union', 'International')
    Group by Location, continent, Population
    ORDER by PercentPopulationInfected DESC;


-- 5.
CREATE VIEW PercentPopulationInfectedByCountryDated AS
    SELECT Location, continent, Population,date, MAX(total_cases) AS HighestInfectionCount,  Max(CAST(total_cases AS float)/population)*100 AS PercentPopulationInfected
    FROM CovidDeaths
    --WHERE location like '%states%'
    WHERE total_cases IS NOT NULL AND continent IS NOT NULL AND location not in ('World', 'European Union', 'International')
    Group by Location, continent, Population, date
    ORDER by PercentPopulationInfected DESC;


--6.
CREATE VIEW percentpopulationvaccinated AS
    SELECT d.continent, d.location, CAST(d.date AS date),
        -- Need to cast new_vaccination as INT to use SUM function
       d.population, CAST(v.new_vaccinations AS numeric), SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_num_vaccinated,
       (SUM(CAST(v.new_vaccinations AS float)) OVER (PARTITION BY d.location ORDER BY d.date) / d.population) * 100 AS percent_of_population
    FROM coviddeaths d
    INNER JOIN covidvaccinations v on d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
    ORDER BY 2,3;









