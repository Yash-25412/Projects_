select * from Covid_deaths
order by 3,4

-- looking upon some total deaths/total cases
-- basically figuring out probability of being facing death if got infeted in our country

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as death_percent 
from Covid_deaths
where location = 'India'
order by 5 desc

-- looking upon percentage of population infected

select location , date , total_cases , population , (total_cases/population)*100 as infected_precent
from Covid_deaths
where location = 'India'
order by 5 desc

select location , date , new_cases,total_cases , population , (total_cases/population)*100 as infected_precent , (new_cases/population)*100 as daily_infect
from Covid_deaths
where location = 'India' and continent is not null
order by daily_infect desc

-- looking upon highest infection rate location wise

 select location , max(total_cases) as maximun_cases , population , (max(total_cases)/population)*100 as infected_percentage
 from Covid_deaths
 where continent is not null
 group by location , population
 order by infected_percentage desc

 -- looking for highest death count/percentage location wise

 select location , max(cast(total_deaths as int)) as maximum_death_count
 from Covid_deaths
 where continent is not null
 group by location
 order by 2 desc

 select location , max(cast(total_deaths as bigint)) as maximum_death_count , population , (max(cast(total_deaths as bigint))/population)*100 as death_percentage
 from Covid_deaths
 where continent is not null
 group by location , population
 order by 4 desc

 -- looking upon some global numbers
 -- basically deaths overall world without any specific location types

 select date , sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as world_death_percent
 from Covid_deaths
where continent is not null
group by date
 order by 1,2 desc


 select  sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as world_death_percent
 from Covid_deaths
where continent is not null

--group by date
 -- order by 1,2 desc

 -- Now looking at some vaccinations data
 select * from Covid_vaccinations

 select d.location,d.population, max(cast(v.total_vaccinations as bigint)),(max(cast(v.total_vaccinations as float))/d.population)*100 as percentage_vaccinated
 from Covid_deaths as d
 join Covid_vaccinations as v
 on d.date=v.date and d.location=v.location
 where d.continent is not null and d.location = 'India'
 group by d.location,d.population
 order by 1

 select d.location, d.date ,v.new_vaccinations,d.population,sum(cast(v.new_vaccinations as float)) 
 OVER (partition by d.location order by d.date ) as rolling_count_of_new_vaccine
 from Covid_deaths as d
 join Covid_vaccinations as v
 on d.date=v.date and d.location=v.location
 where d.continent is not null and d.location = 'India'
 order by 1,2

 -- Using above query as CTE

With population_vaccinated ( Location , Date , New_vaccinations , Population , Rolling_count_vaccines)
as
(select d.location, d.date ,v.new_vaccinations,d.population,sum(cast(v.new_vaccinations as float)) 
 OVER (partition by d.location order by d.date ) as rolling_count_of_new_vaccine
 from Covid_deaths as d
 join Covid_vaccinations as v
 on d.date=v.date and d.location=v.location
 where d.continent is not null
 --order by 1,2
 )
select * ,(Rolling_count_vaccines/Population)*100 as percent_vaccinated
from population_vaccinated
where Location = 'India' and New_vaccinations is not null


-- Temp Table

drop table if exists #rollingcountvaccinations
Create table #rollingcountvaccinations(
Location nvarchar(255),
Date nvarchar(255),
New_vaccinations numeric,
Population numeric,
Rolling_count_vaccines numeric)
insert into #rollingcountvaccinations

select d.location, d.date ,v.new_vaccinations,d.population,sum(cast(v.new_vaccinations as float)) 
 OVER (partition by d.location order by d.date ) as rolling_count_of_new_vaccine
 from Covid_deaths as d
 join Covid_vaccinations as v
 on d.date=v.date and d.location=v.location
 where d.continent is not null
 
 select * ,(Rolling_count_vaccines/Population)*100 as percent_vaccinated
from #rollingcountvaccinations


-- Creating views for further visualizations

create view death_percent_population as 
 select location , max(cast(total_deaths as bigint)) as maximum_death_count , population , (max(cast(total_deaths as bigint))/population)*100 as death_percentage
 from Covid_deaths
 where continent is not null
 group by location , population

 create view world_death_percentage as
  select  sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as world_death_percent
 from Covid_deaths
where continent is not null

create view total_population as
with population_count_world as (select location , population
from Covid_deaths
where continent is not null
group by location , population)

select SUM(population) as total_population
from population_count_world



