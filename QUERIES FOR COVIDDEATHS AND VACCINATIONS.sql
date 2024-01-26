select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--to get death percentage. total deaths vs total cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

--finding the total death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

select date, max(new_cases)
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select date, sum(new_cases),sum(cast(new_deaths as integer))
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2





--next look at countries with the highest infection rate compared to country
select location, max(total_cases) as HighestInfectionCount , population, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--highest death count

select location, max(total_deaths) as Highestdeathcount
from PortfolioProject..CovidDeaths
group by location
order by Highestdeathcount desc

select date, sum(new_cases),sum(cast(new_deaths as integer))
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Global death percentage

select date, sum(new_cases) as GlobalTotalcases,sum(cast(new_deaths as integer)) as GlobalTotalDeaths, sum(cast(new_deaths as integer))/ sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


select sum(new_cases),sum(cast(new_deaths as integer)), sum(cast(new_deaths as integer))/ sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

JOINING COVIDDEATHS AND COVIDVACCINATION

select * 
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..COVIDVACCINATIONS vac
ON dea.location =vac.location
and dea.date = vac.Date
order by 1,2

select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..COVIDVACCINationS vac
ON dea.location =vac.location
and dea.date = vac.Date
where dea.location is not null
order by 2,3

--to see the people that got vaccinated in a population, we do population vs vaccination and because there are 2 tables, 
--we have to specify what table we’re pulling stats from by suing ‘dea’ and ‘vac’

select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..COVIDVACCINationS vac
ON dea.location =vac.location
and dea.date = vac.Date
where dea.continent is not null
order by 2,3

select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsumpeoplevaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..COVIDVACCINationS vac
ON dea.location =vac.location
and dea.date = vac.Date
where dea.continent is not null
order by 2,3

--using CTE
With popvsvac (continent, location, date, population, new_vaccinations, rollingsumpeoplevaccinated)
As
(select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsumpeoplevaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..COVIDVACCINationS vac
ON dea.location =vac.location
and dea.date = vac.Date
where dea.continent is not null
)
Select *
From popvsvac

--applying (rollingsumpeoplevaccinated/population)*100

With popvsvac (continent, location, date, population, new_vaccinations, rollingsumpeoplevaccinated)
As
(select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsumpeoplevaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..COVIDVACCINationS vac
ON dea.location =vac.location
and dea.date = vac.Date
where dea.continent is not null
)
Select *,( rollingsumpeoplevaccinated/population)*100 as percentagevaccinated
From popvsvac

--create view for later visualization

Create view percentagevaccinated as
With popvsvac (continent, location, date, population, new_vaccinations, rollingsumpeoplevaccinated)
As
(select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsumpeoplevaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..COVIDVACCINationS vac
ON dea.location =vac.location
and dea.date = vac.Date
where dea.continent is not null
)
Select *,( rollingsumpeoplevaccinated/population)*100 as percentagevaccinated
From popvsvac





