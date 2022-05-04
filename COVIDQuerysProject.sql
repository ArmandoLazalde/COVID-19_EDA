SELECT *
FROM PortfolioProjects..covid_deaths

--SELECT *
--FROM PortfolioProjects..covid_vaccines

-- Select data that we are going to be using 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentege
FROM PortfolioProjects..covid_deaths
WHERE location = 'Mexico'
ORDER BY 1,2

--Looking at total cases vs total deaths  in Mexico

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentege
FROM PortfolioProjects..covid_deaths
WHERE location = 'Mexico'
ORDER BY 1,2

--Looking at the total cases vs population
-- Shows what percentage of population got COVID

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
