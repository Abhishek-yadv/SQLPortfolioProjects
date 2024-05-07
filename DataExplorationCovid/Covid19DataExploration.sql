/*****************************************/
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths$


SELECT *
FROM PortfolioProject..CovidVaccinations$


SELECT *
FROM PortfolioProject..CovidDeaths$
order by 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations$
order by 3,4


/*****************************************/
SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2


/*****************************************/
/*  total cases vs total deaths */
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
order by 1,2


/*****************************************/
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE location like '%india%'
order by 1,2 


/*****************************************/
/* Total cases vs population */
/* Percentage of population get Covid */
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%india%'
order by 1,2


/*****************************************/
/* Countries with highest Infection rate compared to population */
SELECT Location, Population,MAX(TOTAL_CASES) AS HighestinfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


/*****************************************/
/* Showing countries with highest death count per population */
SELECT Location, Max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
GROUP BY location
ORDER BY TotalDeathCount DESC
/* NError */



/*****************************************/
/* convert varchar255 into integerr */
SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
GROUP BY location
ORDER BY TotalDeathCount DESC
/* NError */


SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


/*NError with corection*/
SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC



/* BREAKING THINGS DOWN BY CONTINENT */
SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



/* NError */
SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT *
FROM CovidDeaths$
where continent is null


/*** NT ***/
SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



/******************************************/
/* BREAKING THINGS DOWN BY CONTINENT */
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY continent
ORDER BY TotalDeathCount DESC



 /******/
 SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC


/******/
-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
group by continent
ORDER BY TotalDeathCount DESC



/******/
-- GLOBAL NUMBERS
SELECT Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Continent is not null
order by 1,2




/******/
SELECT Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2
/* NError */


/******/
SELECT Date,SUM(new_cases)--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2


/******/
SELECT Date,SUM(new_cases), SUM(Cast(new_deaths as int)), SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2


/******/
SELECT Date,SUM(new_cases) AS Total_cases, SUM(Cast(new_deaths as int)) AS Total_deaths,
			SUM(Cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2


/******/
SELECT SUM(new_cases) AS Total_cases, SUM(Cast(new_deaths as int)) AS Total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY Date
ORDER BY 1,2



/**********************************************/
/*********************************************/
/* Looking at total population vs vaccination*/

SELECT *
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date


/* Think about it */
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	FROM PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
ORDER BY 1,2
 



/* Total population vs vaccination */
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


/* Summon new_vaccination */
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location)
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
-- NError Operand data type nvarchar is invalid for sum operator


/******/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location)
/* OR SUM(CONVERT(vac.new_vaccinations, int) */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



/******/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY Dea.location, dea.Date) AS RollingPeopleVaccinated
/* OR SUM(CONVERT(vac.new_vaccinations, int) */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



/******/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY Dea.location, dea.Date) AS RollingPeopleVaccinated
/* OR SUM(CONVERT(vac.new_vaccinations, int) */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


/* Looking at total Population vs Vaccination */
/******/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY Dea.location, dea.Date)
/* OR SUM(CONVERT(vac.new_vaccinations, int) */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


/******/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population) * 100
/* OR SUM(CONVERT(vac.new_vaccinations, int) */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

/* NError without CTE or Temp can't use a
column that you just created to then use the next one */


/************************************/
/***********************************/
/**********************************/
-- USE CTE
with PopvsVac (continent,location, date, population, New_vaccinated, RollingPeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY Dea.location, dea.Date) AS RollingPeopleVaccinated
/* OR SUM(CONVERT(vac.new_vaccinations, int) */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeoplevaccinated/population)*100
FROM PopvsVac



/************************************************/
/************ TEMP TABLE ***********************/
DROP TABLE IF EXISTS #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY Dea.location, dea.Date) AS RollingPeopleVaccinated
/* OR SUM(CONVERT(vac.new_vaccinations, int) */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeoplevaccinated/population)*100
FROM #PercentpopulationVaccinated


/*********************************************************/
/* Creating View to store data for later visualizations */
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccination)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated



/***********************************************/
DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccination)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
     ON dea.location = vac.location
--	 and dea.date = vac.date
	 AND CONVERT(DATETIME, dea.date, 120) = CONVERT(DATETIME, vac.date, 120)
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
GO


