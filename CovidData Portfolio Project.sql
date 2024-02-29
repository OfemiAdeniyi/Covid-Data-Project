SELECT *
FROM ProjectPortfolio..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM ProjectPortfolio..CovidVaccination
--ORDER BY 3,4

--Select Needed Data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2

--Looking at death percentage which is (total_cases/total_death)*100. This represent the likelyhood of death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2

--Looking at Total Cases and Population
--This shows the percentage of population infected with Covid Between Feburary 28, 2020 to April 30, 2021

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is not NULL
ORDER BY 1,2

--Looking at country with Highest Infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is not NULL
Group BY location, population
ORDER BY PercentagePopulationInfected DESC

--Countries with Highest death count per population

SELECT location, MAX (Cast(total_deaths as int)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is not NULL
Group BY location
ORDER BY TotalDeathCount DESC

--VIEWS BY CONTINENT

--Continents with Highest death count per population

SELECT location, MAX (Cast(total_deaths as int)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NULL
Group BY location
ORDER BY TotalDeathCount DESC

--GLOBAL VIEW
--Sum of daily cases, death and the percentage of death

SELECT date, SUM(new_cases) as Total_Cases, SUM (cast(new_deaths as int)) as New_Death, SUM (cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Cases, Total Death and the percentage of death Between Feburary 28, 2020 to April 30, 2021

SELECT SUM(new_cases) as Total_Cases, SUM (cast(new_deaths as int)) as Total_Death, SUM (cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Global Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT Null
Order by 2,3

-- USING CTE
 
 WITH PopvsVAc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT Null
--Order by 2,3
 )

 SELECT *, (RollingPeopleVaccinated/population)*100
 FROM PopvsVac 

 --TEMP TABLE

 DROP TABLE IF EXISTS #PercentagePopulationVaccinated
 CREATE TABLE #PercentagePopulationVaccinated
 (
 Continent nvarchar (255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_Vaccination numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentagePopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT Null
--Order by 2,3

 SELECT *, (RollingPeopleVaccinated/population)*100
 FROM #PercentagePopulationVaccinated 

--CREATING VIEWS FOR LATER VISUALIZATION

CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations  vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT Null
--Order by 2,3
