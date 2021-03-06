select *
from PortfolioProject ..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject ..CovidVaccinations
--order by 3,4

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject ..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
-- where location like '%states%'
where continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as
PercentPopulationInfected
from PortfolioProject ..CovidDeaths
-- where location like '%states%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..CovidDeaths
-- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--let's bring things down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- if we set it as null
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..CovidDeaths
-- where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

-- showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc





-- global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from PortfolioProject ..CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null


-- use cte

with popsvac(continent, location, date,population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from popsvac

--temp table

create table #PercentPopuVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopuVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null


--creating view view to store data for later visualizations
create view PercentPopuVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopuVaccinated
