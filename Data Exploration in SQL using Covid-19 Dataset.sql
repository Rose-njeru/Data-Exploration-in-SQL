 /* 
 Covid 19 Data Exploration 
Skills used: Joins, CTE's,  Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
-- overview of  the Covid-19  data

SELECT *
FROM `portfolio project`.`covid vaccinations`;

-- Covid-19 in Kenya

SELECT *
 FROM `portfolio project`.`covid vaccinations`
 WHERE
 location ='Kenya' ;
 
 -- Covid-19 in  Africa
 SELECT *
 FROM `portfolio project`.`covid-19 deaths`  
 WHERE continent IS NOT NULL
 AND location LIKE'%Africa%' ;

 -- total cases vs population
 
SELECT location,population,MAX(total_cases)AS highest_infection_count,max(total_cases/population)*100
AS percent_pop_infected
 FROM `portfolio project`.`covid-19 deaths`
-- where location like '%Africa%'
 GROUP BY location,population
 ORDER BY percent_pop_infected desc; 
 
 -- countries with the highest death count
 
 SELECT location,MAX(CAST(total_deaths AS unsigned)) AS total_death_count
FROM `portfolio project`.`covid-19 deaths`
-- where location  like '%Africa%'
WHERE location <> 'High income'
GROUP BY  location
ORDER BY total_death_count desc ;
 
-- breakdown by continent
-- continent with the highest death count

 SELECT continent, MAX(CAST(Total_deaths AS unsigned)) AS TotalDeathCount
FROM `portfolio project`.`covid-19 deaths`
-- Where location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc;

--  Global Numbers

SELECT SUM(new_cases)AS total_cases,SUM(CAST(new_deaths AS unsigned )) AS total_deaths,
SUM(CAST(new_deaths AS unsigned))/SUM(new_cases) AS death_percentage
FROM `portfolio project`.`covid-19 deaths`
-- where location like '%Africa%'
WHERE continent IS NOT NULL
 ORDER BY 1,2; 
 
 -- total cases vs population
-- Percentage of the population infected

 SELECT location,date,population,total_cases,(total_cases/population)*100 AS percent_population_infected
FROM `portfolio project`.`covid-19 deaths`   
WHERE location LIKE '%Africa%'
ORDER BY 1,2; 

-- countries with highest infection rate compared to population

SELECT location, population,date,MAX(total_cases) AS highest_infection_count,
  MAX(total_cases/population)*100 AS percent_population_infected 
  FROM `portfolio project`.`covid-19 deaths`    
  -- WHERE location like'% Africa%'   
GROUP BY location,population,date
ORDER BY percent_population_infected DESC;

-- total vaccinations vs populations

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
FROM `portfolio project`.`covid-19 deaths`AS dea
JOIN `portfolio project`.`covid vaccinations` AS vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY  2,3; 

-- cumulative people vaccinated using Window functions

SELECT dea.continent, dea.location,dea.date,dea.population,
SUM(CAST(vac.new_vaccinations AS unsigned)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date
) AS rolling_people_vaccinated
FROM`portfolio project`.`covid-19 deaths`AS dea
JOIN `portfolio project`.`covid vaccinations` AS vac
ON dea.location=vac.location
AND dea.date=vac.date
-- WHERE continent IS NOT NULL
ORDER BY 2,3; 

-- rolling people vaccinated vs population using CTE's

WITH popvsvacc (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
AS
(SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS unsigned)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date
) AS rolling_people_vaccinated
FROM `portfolio project`.`covid-19 deaths`AS dea
JOIN`portfolio project`.`covid vaccinations` AS vac
ON dea.location=vac.location
AND dea.date=vac.date
-- WHERE continent IS NOT NULL
ORDER BY 2,3)
  
SELECT *,(rolling_people_vaccinated/population)*100
FROM popvsvacc; 

-- creating view for later Vizualization

CREATE VIEW  percentpopulationvaccinated AS
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS unsigned)) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
 FROM `portfolio project`.`covid-19 deaths`AS dea
JOIN `portfolio project`.`covid vaccinations`AS vac
ON dea.location=vac.location
AND  dea.date=vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- view

SELECT * 
FROM `portfolio project`.percentpopulationvaccinated;
 

