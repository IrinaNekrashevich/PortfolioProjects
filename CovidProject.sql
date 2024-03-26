SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathrate
FROM CovidDeaths
WHERE (location like '%stan' or location like '%states%') AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location = 'Australia' AND continent IS NOT NULL
ORDER BY 1,2



-- Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Showing countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- break things down by continent
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Showing continents with Highest Death Count
-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as newCasesDay, SUM(cast(new_deaths as int)) as newDeathsDay, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--without groupping we get global numbers
SELECT SUM(new_cases) as newCasesDay, SUM(cast(new_deaths as int)) as newDeathsDay, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total population vs Vaccination 
-- With creating CTE
WITH PopVSvac (Continent, Location, Date, Population, New_vaccinations, Total_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.total_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated --you can not use just created column for calculations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, RollingPeopleVaccinated/Population*100 as RollingVacVSpop
FROM PopVSvac

-- Use Temp table

DROP TABLE if exists #PercentPopulationVaccinated --add this command in case you need to add some changes to the Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated --you can not use just created column for calculations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, RollingPeopleVaccinated/Population*100 as RollingVacVSpop
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated --you can not use just created column for calculations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

CE

 