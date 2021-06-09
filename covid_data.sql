/* 
This file walks through some SQL commands I used to analyse 
the Covid-19 data available at ourworldindata.org

It includes explanations of queries and demonstrates 
my command of basic SQL (written in MySQL) and ability to use 
it in the context of a real project.

*/

-- Loads data
LOAD DATA LOCAL infile '/Users/isaacgrove/Desktop/covid_project/coviddeaths.csv' 
INTO TABLE coviddeaths FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' IGNORE 1 rows;

-- Initial look / "EDA"
SELECT * FROM covid_project.coviddeaths;

-- Shows how the Covid death rate in the United States developed over time
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS death_rate
FROM covid_project.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Shows what percentage of the population became infected over time.
-- WHERE clause limits results to only the United States as no other country
-- names contain those characters
SELECT location, date, total_cases, population, (total_cases/population*100) AS infected_rate
FROM covid_project.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Orders countries by percentage infected to date, in descending order
SELECT location, MAX(total_cases) AS cases, MAX(population) AS population, 
MAX(total_cases)/MAX(population)*100 AS percent_infected_to_date
FROM covid_project.coviddeaths
GROUP BY 1
ORDER BY 4 DESC;

-- Orders countries by how much of their population has been killed to date.
-- WHERE clause excludes records given by continent (in those records, "Continent"
-- is null and Location contains the continent name)
SELECT location, MAX(total_deaths) AS total_deaths, MAX(population) AS population, 
	MAX(total_deaths)/MAX(population)*100 AS percent_dead_to_date
FROM covid_project.coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC;

-- Death totals by continent
-- Note the opposite WHERE condition to the previous query
SELECT location, MAX(total_deaths) AS total_deaths
FROM covid_project.coviddeaths
WHERE continent IS NULL
GROUP BY 1
ORDER BY 2 DESC;

-- Global case and death counts
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_project.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3 DESC;

-- I also created a "vaccinations" table with a different subset of columns
-- LIMIT helps optimize a little bit - we don't need to see all the data
select * from covid_project.covidvaccinations LIMIT 5;


-- Total Population Vaccinated (via Common Table Expression)
WITH pop_vacc AS (SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY date) AS running_total_vaccinated
from covid_project.coviddeaths d
JOIN covid_project.covidvaccinations v
ON d.location = v.location and d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3)

SELECT *, running_total_vaccinated/population*100 AS running_percent_vaccinated
FROM pop_vacc
WHEre location = 'Germany' OR location = 'United States';

-- Creates a view to store data for later visualizations,
-- joining "deaths" and "vaccinations" tables, excluding information given
-- by continent, and providing a running total of persons vaccinated in
-- each country
CREATE VIEW covid_project.percent_population_vaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY date) AS running_total_vaccinated
from covid_project.coviddeaths d
JOIN covid_project.covidvaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;