Select *
from PortfolioProject..CovidDeaths$
where continent is not null

Select *
from PortfolioProject..CovidVaccinations$
order by 3,4

--Select data that we will be using

Select top 1000 Location, date, total_cases, new_cases, total_deaths, new_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Look at total Cases vs Total deaths
--Shows likelihood of dying if you contract covid in Canada

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float) /total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Canada'
order by 1,2


--Looking at the total cases vs Population
--Shows what percentage of population got covid

Select Location, date, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Canada'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Canada'
where continent is not null
Group by Location, population
order by CovidPercentage desc

--Showing countries with highest death count per Population

Select Location, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Canada'
where continent is not null
Group by Location
order by TotaldeathCount desc

-- Let's break things by continent

-- Showing the continents with the highest death counts

Select continent, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Canada'
where continent is not null
Group by continent
order by TotaldeathCount desc

-- Global Numbers

Select date,sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths
,sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Canada'
group by date
order by 1,2

--checking for total population 

Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths
,sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Canada'
order by 1,2


--Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USe CTE

with popvsvac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from popvsvac

--TEMP TABLE
drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentpopulationVaccinated


--creating view to stor data for later visualisations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc