SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--Total deaths vs Total cases

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS decimal)/total_cases * 100 AS death_percentage
FROM CovidDeaths
ORDER BY 1, 2

--Total cases vs Population
SELECT location, date, total_cases, population, CAST(total_cases AS decimal)/population*100 AS PercentPopulation
FROM CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1, 2

--Countries with highest infection rate vs Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS decimal)/population*100) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS TotalDeathCount, MAX(CAST(total_deaths AS decimal)/population*100) AS PercentPopulationDied
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount desc

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL SUM
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(CAST(new_deaths AS decimal))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1, 2 desc

SELECT *
FROM CovidDeaths





SELECT *
FROM CovidVaccinations

--Total Population vs Vaccinations
SELECT cod.location, cod.date, cod.population, cov.new_vaccinations
FROM CovidDeaths cod
JOIN CovidVaccinations cov
	ON cod.location = cov.location
	and cod.date = cov.date
WHERE cod.continent IS NOT NULL
ORDER BY 1,2,3

SELECT cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
	SUM(cov.new_vaccinations) OVER (PARTITION BY cod.location ORDER BY cod.location
	, cod.date) AS ProgressiveVac
FROM CovidDeaths cod
JOIN CovidVaccinations cov
	ON cod.location = cov.location
	and cod.date = cov.date
WHERE cod.continent IS NOT NULL

--Using CTE
With PopVSvac (continent, location, date, population, new_vaccinations, ProgressiveVac)
AS (
SELECT cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
	SUM(cov.new_vaccinations) OVER (PARTITION BY cod.location ORDER BY cod.location
	, cod.date) AS ProgressiveVac
FROM CovidDeaths cod
JOIN CovidVaccinations cov
	ON cod.location = cov.location
	and cod.date = cov.date
WHERE cod.continent IS NOT NULL
)
SELECT *, (ProgressiveVac/population)*100
FROM PopVSvac

--Creating views to store data for later visualizations

CREATE VIEW PopVSvac AS (
SELECT cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
	SUM(cov.new_vaccinations) OVER (PARTITION BY cod.location ORDER BY cod.location
	, cod.date) AS ProgressiveVac
FROM CovidDeaths cod
JOIN CovidVaccinations cov
	ON cod.location = cov.location
	and cod.date = cov.date
WHERE cod.continent IS NOT NULL
)

--View 2

CREATE VIEW Vaccinations_Population AS (
SELECT cod.location, cod.date, cod.population, cov.new_vaccinations
FROM CovidDeaths cod
JOIN CovidVaccinations cov
	ON cod.location = cov.location
	and cod.date = cov.date
WHERE cod.continent IS NOT NULL
)
