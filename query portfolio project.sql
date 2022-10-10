Select *
From PortfolioProject..CovidDeaths
where continent is not null and location = 'canada'
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%indonesia%'
order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, Date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
where location like '%indonesia%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by Location, population
--where location like '%indonesia%'
order by PercentPopulationInfected desc


-- Showing Countries with Hoghest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
--where location like '%indonesia%'
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOW BY CONTINENT
-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage
--, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population,
New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea. location, dea.date,
dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) 
OVER (partition by dea.location 
order by dea.location, dea.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea. location, dea.date,
dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) 
OVER (partition by dea.location 
order by dea.location, dea.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea. location, dea.date,
dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) 
OVER (partition by dea.location 
order by dea.location, dea.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
from PercentPopulationVaccinated