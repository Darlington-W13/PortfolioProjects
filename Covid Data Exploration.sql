SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covid_vaccinations
--ORDER BY 3,4 

--Select the Data that we're going to be using for our exploration procedure/process.

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1,2

--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathrate
FROM PortfolioProject..covid_deaths
WHERE location like '%nigeria%'
ORDER BY 1,2

--Total Cases vs Population
--Shows the % of opoplation that contracted COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS contract_intensity
FROM PortfolioProject..covid_deaths
--WHERE location = 'Nigeria'
ORDER BY 1,2

--Determining the highest infectionrates OR contracting_intensities in comparison to Population

SELECT location,MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) AS InfectionPercentage
FROM PortfolioProject..covid_deaths
--WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY 1,2

--Showing the mortality rate(highest death count/population)

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking Down Exploration by CONTINENT

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 DESC


-- Total Population against Vaccination (Using the JOIN clause statement to join two tables with a primary key)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Aggregated_Vacc
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY  2, 3



--USE CTE (Common Table Expression)

WITH PopVsVacc (continent, location, date, population, new_vaccinations, Aggregated_Vacc)
AS
	(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Aggregated_Vacc
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * ,(Aggregated_Vacc/Population)*100 AS 'PopVacc%'
FROM PopVsVacc


--TEMPORARY TABLE

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Aggregated_Vacc numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Aggregated_Vacc
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY  2, 3
SELECT * 
FROM #PercentPopulationVaccinated



--Creating VIEW to store data for later Visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Aggregated_Vacc
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY  2, 3

SELECT *
FROM PercentPopulationVaccinated
