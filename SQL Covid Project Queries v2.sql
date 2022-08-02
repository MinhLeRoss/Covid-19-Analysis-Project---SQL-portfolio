--Minh Ross - Covid Analysis project
select * 
from [Portfolio project]..CovidDeaths$
Where continent is not null 
order by 3,4


--select * 
--from [Portfolio project]..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population  
from [Portfolio project]..CovidDeaths$
order by 1,2

--Investigating Total cases vs Total deaths
--Shows the survival rate if you contract Covid 19 in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
from [Portfolio project]..CovidDeaths$
order by 1,2

--Shows the death rate if you contract Covid 19 in specifically United Kingdom

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
from [Portfolio project]..CovidDeaths$
where location like '%kingdom%'
order by 1,2

--Shows what percentage of the population contracted Covid 19 - specifically United Kingdom

select location, date, total_cases, population, (total_cases/population)*100 AS ContractingPercentage 
from [Portfolio project]..CovidDeaths$
where location like '%kingdom%'
order by 1,2
  
--Looking at countries with Highest Infection Rate compared to population

select location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS InfectionRate 
from [Portfolio project]..CovidDeaths$
group by population, location
order by InfectionRate desc

--Showing countries with the Highest Death Count per population
--total deaths column shows 'nvarchar 255' - possible fault in how the data is rendered? - CAST as integer

select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio project]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio project]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest infection rate

select continent, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS InfectionRate 
from [Portfolio project]..CovidDeaths$
where continent is not null
group by population, continent
order by InfectionRate desc

--Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
from [Portfolio project]..CovidDeaths$
where continent is not null

order by 1,2

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopsVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopsvsVac 

--TEMP table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating View to store data for visualisation (Tableau, etc.)

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create view GlobalDeathRate as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
from [Portfolio project]..CovidDeaths$
where continent is not null

--order by 1,2

create view ContinentalInfectionrate as
select continent, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS InfectionRate 
from [Portfolio project]..CovidDeaths$
where continent is not null
group by population, continent
--order by InfectionRate desc


create view ContinentalDeathCount as
select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio project]..CovidDeaths$
where continent is not null
group by continent
--order by TotalDeathCount desc

create view CountriesDeathCount as
select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio project]..CovidDeaths$
where continent is not null
group by location
--order by TotalDeathCount desc

create view CountriesInfectionRate as
select location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS InfectionRate 
from [Portfolio project]..CovidDeaths$
group by population, location
--order by InfectionRate desc

Create view DeathRate as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
from [Portfolio project]..CovidDeaths$
--order by 1,2












