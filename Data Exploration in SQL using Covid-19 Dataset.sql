 /* 
 Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
-- overview of  the Covid-19  data

select *
from `portfolio project`.`covid vaccinations`;

-- Covid-19 in Kenya

SELECT *
 FROM `portfolio project`.`covid vaccinations`
 where 
 location ='Kenya' ;
 
 -- Covid-19 in  Africa
 SELECT *
 FROM `portfolio project`.`covid-19 deaths`  
 where continent is not null
 and location like'%Africa%' ;

 -- total cases vs population
 
select location,population,max(total_cases) as highest_infection_count,max(total_cases/population)*100
 as percent_pop_infected
 from `portfolio project`.`covid-19 deaths`
-- where location like '%Africa%'
 group by location,population
 order by percent_pop_infected desc; 
 
 -- countries with the highest death count
 
 select location,max(cast(total_deaths as unsigned)) as total_death_count
from `portfolio project`.`covid-19 deaths`
-- where location  like '%Africa%'
where location <> 'High income'
group by location
order by total_death_count desc ;
 
-- breakdown by continent
-- continent with the highest death count

 Select continent, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
From `portfolio project`.`covid-19 deaths`
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

--  Global Numbers

select sum(new_cases)as total_cases,sum(cast(new_deaths as unsigned )) as total_deaths,
sum(cast(new_deaths as unsigned))/sum(new_cases) as death_percentage
from `portfolio project`.`covid-19 deaths`
-- where location like '%Africa%'
where  continent is not null
 order by 1,2; 
 
 -- total cases vs population
-- Percentage of the population infected

 select location,date,population,total_cases,(total_cases/population)*100 as percent_population_infected
from `portfolio project`.`covid-19 deaths`   
where location like '%Africa%'
order by 1,2; 

-- countries with highest infection rate compared to population

select location, population,date,max(total_cases) as highest_infection_count,
  max(total_cases/population)*100 as percent_population_infected 
  FROM `portfolio project`.`covid-19 deaths`    
  -- where location like'% Africa%'   
group by location,population,date
order by percent_population_infected desc;

-- total vaccinations vs populations

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
from `portfolio project`.`covid-19 deaths`as dea
 join `portfolio project`.`covid vaccinations` as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3; 

-- cumulative people vaccinated using Window functions

select dea.continent, dea.location,dea.date,dea.population,
sum(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location,dea.date
) as rolling_people_vaccinated
from `portfolio project`.`covid-19 deaths`as dea
 join `portfolio project`.`covid vaccinations` as vac
on dea.location=vac.location
and dea.date=vac.date
-- where continent is not null
order by 2,3; 

-- rolling people vaccinated vs population using CTE's

with popvsvacc (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
 as 
(select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location,dea.date
) as rolling_people_vaccinated
from `portfolio project`.`covid-19 deaths`as dea
 join `portfolio project`.`covid vaccinations` as vac
on dea.location=vac.location
and dea.date=vac.date
-- where continent is not null
order by 2,3)
select *,(rolling_people_vaccinated/population)*100
from popvsvacc; 

-- creating view for later Vizualization

create view percentpopulationvaccinated as
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
 FROM `portfolio project`.`covid-19 deaths`as dea
 join `portfolio project`.`covid vaccinations` as vac
 on dea.location=vac.location
 and  dea.date=vac.date
 where dea.continent is not null
order by 2,3;

-- view

SELECT * 
FROM `portfolio project`.percentpopulationvaccinated;
 

