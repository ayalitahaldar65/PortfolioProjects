SELECT*
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT*
--FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY 3,4

 SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM [Portfolio Project]..CovidDeaths$
 WHERE continent IS NOT NULL
 ORDER BY 1,2

 --total cases vs total deaths
 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 FROM [Portfolio Project]..CovidDeaths$
 WHERE location LIKE '%marino%'
 ORDER BY 1,2

 --total cases vs population
 SELECT Location, date, population, total_cases , (total_cases/population)*100 AS PopulationPercentage
 FROM [Portfolio Project]..CovidDeaths$
 WHERE location LIKE '%iceland%'
 ORDER BY 1,2

 --countries with highest infection rates
 SELECT Location, population, MAX(total_cases) AS HighestCases , MAX((total_cases/population))*100 AS HighestPopulationPercentage
 FROM [Portfolio Project]..CovidDeaths$
 GROUP BY location, population
 ORDER BY HighestPopulationPercentage desc

 --countries with highest death count
SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--on the basis of CONTINENT
-- #1 to add all the continents
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--#2 filtered continents
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--continents with highest death count
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--global numbers
SELECT date, SUM(new_cases)AS total_cases, SUM(cast(new_deaths AS INT))AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS NewDeathPercentage--,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--global death percentage
SELECT SUM(new_cases)AS total_cases, SUM(cast(new_deaths AS INT))AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS NewDeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--joining two tables
--vaccinations rate among total population
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated,

FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

