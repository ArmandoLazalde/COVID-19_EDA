/*

COVID 19 Data Exploration with SQL Server 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProjects..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data that we are going to be starting with

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentege
FROM PortfolioProjects..covid_deaths
WHERE location = 'Mexico'
ORDER BY 1,2

--Looking at total cases vs total deaths in Mexico

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentege
FROM PortfolioProjects..covid_deaths
WHERE location = 'Mexico'
ORDER BY 1,2

--Looking at the total cases vs population
-- Shows what percentage of population infected with COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS population_infected_Percentege
FROM PortfolioProjects..covid_deaths
WHERE location = 'Mexico'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS population_infected_Percentege
FROM PortfolioProjects..covid_deaths
GROUP BY location, population
ORDER BY population_infected_Percentege DESC

-- Showing countries with highest death count per population

 SELECT location, MAX(CAST(total_deaths AS INT)) as Total_deaths_count
FROM PortfolioProjects..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_deaths_count DESC
 
 -- Show continents with the highest death count per population

  SELECT location, MAX(CAST(total_deaths AS INT)) as Total_deaths_count
FROM PortfolioProjects..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_deaths_count DESC

-- Global numbers

SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS BIGINT)) AS Total_deaths, (SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases))*100 as DeathPercentege
FROM PortfolioProjects..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS BIGINT)) AS Total_deaths, (SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases))*100 as DeathPercentege
FROM PortfolioProjects..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Population vs vaccinations. 
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..covid_deaths dea
JOIN PortfolioProjects..covid_vaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using a CTE (Common Table Expression) to perform calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
FROM PortfolioProjects..covid_deaths dea
JOIN PortfolioProjects..covid_vaccines vac
	ON  dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM  PopvsVac


-- Using Temp Table to perform calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..covid_deaths dea
JOIN PortfolioProjects..covid_vaccines vac
	ON  dea.location = vac.location
	and dea.date = vac.date


SELECT *, (RollingPeopleVaccinated/population)*100 
FROM  #PercentPopulationVaccinated

-- Creating view to store data 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..covid_deaths dea
JOIN PortfolioProjects..covid_vaccines vac
	ON  dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated