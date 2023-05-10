SELECT *
FROM PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of death from contracting covid in your Country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
Where location = 'United States'
order by 1,2

-- Looking at the total cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as Cases_by_Population
FROM PortfolioProject1..CovidDeaths
-- WHERE location = 'United States'
order by 1,2

-- What country has the highest infection rate compared to population
SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject1..CovidDeaths
GROUP BY location, population
order by InfectionPercentage DESC

-- Showing Countries with Highest Death Count per Population
-- Data from total_deaths read as nvarchar(255)..to correct and return an appropriate query cast total_deaths as an integer
-- Data from continent has nulls and querying without 'WHERE continent is not null' will return irrelevant data in the location column
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
Group by location
order by TotalDeaths DESC

-- Breaking TotalDeaths down by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject1..CovidDeaths
WHERE continent is null
Group by location
order by TotalDeaths DESC

-- Global cases and deaths by day
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
Where continent is not null
group by date
order by 1,2

-- Total global cases and deaths plus percentage
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
Where continent is not null
order by 1,2

-- Joining both imported tables by location and date
-- dea and vac after both tables work as aliases to easily navigate querying
SELECT *
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinates/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinates/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT * FROM popvsvac

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations int,
rollingpeoplevaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinates/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as totalvaccinations
FROM #PercentPopulationVaccinated

-- Creating a  view for Visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinates/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null





