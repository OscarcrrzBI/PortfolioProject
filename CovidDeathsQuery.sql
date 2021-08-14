

-- COVID Data 
-- Dataset extracted from https://ourworldindata.org/covid-deaths 
-- Date extracted: 08/08/2021
-- Creator: Oscar Cruz Ruiz

USE [Portfolio Project]

Select * 
From CovidDeaths
Order by 3,4

-- Select Data that we are going to be using
SELECT  Location
	  , date
	  , total_cases
	  , new_cases
	  , total_deaths
	  , population
FROM [Portfolio Project].[dbo].[CovidDeaths]
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths (Mexico)

SELECT  Location
      , date
	  , total_cases
	  , total_deaths
	  , (total_deaths/total_cases)* 100 AS DeathPercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
WHERE location = 'United States' 
ORDER BY 1,2


-- Looking at Total Cases vs Population (United States)
SELECT  Location
      , Date
	  , Population
	  , total_cases
	  , (total_cases/population)* 100 AS ContagiousPercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
WHERE location = 'United States' 
ORDER BY total_cases DESC;



-- Looking at Countries with Highest Infection Rate compared to Population

SELECT  Location
	  , Population
	  , MAX(total_cases) AS HighestInfectionCount
	  , MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths]
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count per Population 

SELECT  Location
	  , MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


--Showing Countries with Highest Death Count per Population (Continents)

SELECT  Location
	  , MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
WHERE continent is NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Global data
-- Daily cases and deaths worldwide and percentage

SELECT date
	   , SUM(new_cases) AS TotalCases
	   , SUM(CAST(new_deaths AS int)) AS TotalDeaths
	   , ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)* 100,2) AS DeathPercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
WHERE continent is not NULL
GROUP BY date
ORDER BY 1, 2

--Total cases and deaths worldwide with percentage

SELECT   SUM(new_cases) AS TotalCases
	   , SUM(CAST(new_deaths AS int)) AS TotalDeaths
	   , ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)* 100, 2) AS DeathPercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
WHERE continent is not NULL
ORDER BY 1, 2


--Looking at Total Population vs Vaccinations

SELECT CD.continent
	  ,CD.location
	  ,CD.date
	  ,CD.population
	  ,CV.new_vaccinations
	  ,SUM(CAST(CV.new_vaccinations as int)) OVER (PARTITION by CD.Location ORDER BY CD.location, CD.date) AS PeopleVaxxed
FROM [Portfolio Project].[dbo].[CovidDeaths] AS CD
INNER JOIN [Portfolio Project].[dbo].[CovidVaccinations] AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY location, date

-- USING CTE

WITH PopvsVax (Continent, location, date, population, new_vaccinations, PeopleVaxxed)
AS
(
SELECT CD.continent
	  ,CD.location
	  ,CD.date
	  ,CD.population
	  ,CV.new_vaccinations
	  ,SUM(CAST(CV.new_vaccinations as int)) OVER (PARTITION by CD.Location ORDER BY CD.location, CD.date) AS PeopleVaxxed
FROM [Portfolio Project].[dbo].[CovidDeaths] AS CD
INNER JOIN [Portfolio Project].[dbo].[CovidVaccinations] AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL AND CD.Location = 'United States'
)
SELECT *, (PeopleVaxxed/population) * 100 AS VaxPercentage
FROM PopvsVax