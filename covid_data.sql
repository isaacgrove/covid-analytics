-- EDA
SELECT * FROM alex_the_analyst_project.coviddeaths;


-- Looks at total cases versus total deaths over time
-- Shows moving covid death rate in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS death_rate
FROM alex_the_analyst_project.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looks at Total Cases vs Population
-- Shows what percentage of the population got Covid over time
SELECT location, date, total_cases, population, (total_cases/population*100) AS infected_rate
FROM alex_the_analyst_project.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Countries with the highest infection rate
SELECT location, MAX(total_cases) AS cases, MAX(population) AS population, MAX(total_cases)/MAX(population)*100 AS percent_infected_to_date
FROM alex_the_analyst_project.coviddeaths
GROUP BY 1
ORDER BY 4 DESC;

-- Countries with the highest death count per population
SELECT location, MAX(total_deaths) AS total_deaths, MAX(population) AS population, 
	MAX(total_deaths)/MAX(population)*100 AS percent_infected_to_date
FROM alex_the_analyst_project.coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC;

-- Death totals by continent 
SELECT location, MAX(total_deaths) AS total_deaths
FROM alex_the_analyst_project.coviddeaths
WHERE continent IS NULL
GROUP BY 1
ORDER BY 2 DESC;

-- global numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM alex_the_analyst_project.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3 DESC;

-- vaccinations table
select * from alex_the_analyst_project.covidvaccinations LIMIT 5;

SELECT * FROM alex_the_analyst_project.coviddeaths LIMIT 5;

-- Total Population Vaccinated (via CTE)
WITH pop_vacc AS (SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY date) AS running_total_vaccinated
from alex_the_analyst_project.coviddeaths d
JOIN alex_the_analyst_project.covidvaccinations v
ON d.location = v.location and d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3)

SELECT *, running_total_vaccinated/population*100 AS running_percent_vaccinated
FROM pop_vacc
WHEre location = 'Germany' OR location = 'United States';

-- Total Population Vaccinated (via temp table)
/* DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
Running_percent_vaccinated numeric)

INSERT INTO #PercentPopVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY date) AS running_total_vaccinated
from alex_the_analyst_project.coviddeaths d
JOIN alex_the_analyst_project.covidvaccinations v
ON d.location = v.location and d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, running_total_vaccinated/population*100 AS running_percent_vaccinated
FROM pop_vacc
WHEre location = 'Germany' OR location = 'United States'; */


-- Creating view to store data for later visualizations
CREATE VIEW alex_the_analyst_project.percent_population_vaccinatedpercent_population_vaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY date) AS running_total_vaccinated
from alex_the_analyst_project.coviddeaths d
JOIN alex_the_analyst_project.covidvaccinations v
ON d.location = v.location and d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2, 3