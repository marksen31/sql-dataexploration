select * 
from SQLTutorial..Covid_deaths
where continent is not null
order by 3, 4

select *
from SQLTutorial..Covid_vaccination
order by 3,4

select location, date, total_cases, total_deaths, population
from SQLTutorial..Covid_deaths
order by 1,2

--death percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from SQLTutorial..Covid_deaths
where location like 'India' and continent is not null
order by total_cases desc

--show what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from SQLTutorial..Covid_deaths
where location like 'India'
and continent is not null
order by 5 desc

--Looking at countries with highest infection count compared to population
select location, population, max (total_Cases) as highestinfectioncount, max (total_cases/population)*100 as percentpopulationinfected
from SQLTutorial..Covid_deaths
where continent is not null
group by location, population
order by 3 desc

--Highest death count
select location, max (cast (total_deaths as int)) as totaldeathcount
from SQLTutorial..Covid_deaths
where continent is not null
group by location
order by 1 asc

select * 
from SQLTutorial..Covid_deaths
where location like 'canada'


select continent, max (cast (total_deaths as int)) as totaldeathcount
from SQLTutorial..Covid_deaths
where continent is not null
group by continent
order by totaldeathcount desc

--GLOBAL NUMBERS

select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent 
from SQLTutorial..Covid_deaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent 
from SQLTutorial..Covid_deaths
where continent is not null
order by 1,2

--Deaths and vaccination combined
select *
from SQLTutorial..Covid_deaths death
join SQLTutorial..Covid_vaccination vac
on death.location = vac.location
and death.date = vac.date



select death.continent, death.location, death.date, death.population, sum(cast(vac.new_vaccinations as int))
from SQLTutorial..Covid_deaths death
join SQLTutorial..Covid_vaccination vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
group by death.continent, death.location, death.date, death.population
order by 5 desc

--Rolling people vaccination
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as rollingpplvaccinated
from SQLTutorial..Covid_deaths death
join SQLTutorial..Covid_vaccination vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null

 
--USING CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpplvaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as rollingpplvaccinated
from SQLTutorial..Covid_deaths death
join SQLTutorial..Covid_vaccination vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
)

select *, (rollingpplvaccinated/population)*100 rollingpercent
from popvsvac
where location like '%states%'

--TEMP TABLES

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingvaccination numeric
)

insert into #percentpopulationvaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as rollingpplvaccinated
from SQLTutorial..Covid_deaths death
join SQLTutorial..Covid_vaccination vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null

select * from #percentpopulationvaccinated
where location like 'India'

 
create table percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingvaccination numeric
)

insert into #percentpopulationvaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as rollingpplvaccinated
from SQLTutorial..Covid_deaths death
join SQLTutorial..Covid_vaccination vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null


