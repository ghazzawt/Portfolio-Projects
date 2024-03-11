select *
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4


--select *
--From [Portfolio Project]..CovidVaccination
--order by 3,4

-- select data that we will use

select location, date , total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

--looking at the total cases vs the population
-- shows what percentage of the population got covid

select location, date , population , total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location , population , MAX(total_cases) AS HighestInfrectionCount, max((total_cases/population))*100 as PercentOfPopulationInfected
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercentOfPopulationInfected desc

--This is showing the countries with the highest Death Count per population

--BREAKING DOWN BY CONTINENT

select continent , max(cast(Total_Deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing the Continents with the highest death count

select location , max(cast(Total_Deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


-- Global numbers

select date , sum(new_cases) as TotalCases , sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/ sum(new_cases)* 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2


-- looking at total population vs vaccinations


select*
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE


with PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
data datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)


insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
From #PercentpopulationVaccinated


-- creating view to store data for later visualizations

use [Portfolio Project]
GO
create view PercentpopulationVaccinatedd as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--using view

select *
from PercentpopulationVaccinatedd
