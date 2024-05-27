SELECT*
FROM [Portfolio project].dbo.coviddeaths
ORDER BY 3,4

SELECT*
FROM [Portfolio project].dbo.CovidVaccinations
ORDER BY 3,4

--select relevant data from the table for detailed querying

SELECT location,date,population,total_cases,total_deaths
FROM [Portfolio project].dbo.coviddeaths
ORDER BY 1,2
--looking at total cases vs total deaths
--showing likelyhood of death if contracted covid in your country

SELECT location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM [Portfolio project].dbo.coviddeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--looking at total cases vs population
--shows the percentage of population got covid 

SELECT location,date,population,total_cases,(total_cases/population)*100 as covid_percentage
FROM [Portfolio project].dbo.coviddeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--we are looking at thecountries with highest infection rate

SELECT location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as percentage_population_infection
FROM [Portfolio project].dbo.coviddeaths
GROUP BY location, population
ORDER BY percentage_of_infection desc

--- india is at the 101 th in the list of highest infection rate, with their highest percentage infection of 1.38876....,

SELECT location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as percentage_population_infection
FROM [Portfolio project].dbo.coviddeaths
where location like '%india%'
GROUP BY location, population
ORDER BY percentage_of_infection desc

--looking at the countries having highest death count

SELECT location, population,max(cast(total_deaths as int)) as total_death_count
FROM [Portfolio project].dbo.coviddeaths
where continent is not null
GROUP BY location, population
ORDER BY total_death_count desc

---United states has the highest total death count



--also looking at the countries with highest death per population rate

SELECT location, population, max(total_deaths) as highest_death_count, max((total_deaths/population)*100) as percentage_population_death
FROM [Portfolio project].dbo.coviddeaths
GROUP BY location, population
ORDER BY percentage_population_death desc

--lets break things down to continents


SELECT location,max(cast(total_deaths as int)) as total_death_count
FROM [Portfolio project].dbo.coviddeaths
where continent is null
GROUP BY location
ORDER BY total_death_count desc


--Global numbers

SELECT date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/max(new_cases)*100 as death_percentage
FROM [Portfolio project].dbo.coviddeaths
where continent is not null
GROUP BY date
ORDER BY date


--looking at total population vs total people vaccinated

select*
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
     on vac.location=dea.location
	 and vac.date=dea.date

--CTE 


with popvsvac(continent,location,date,population,new_vaccinations,totalnewvaccinations)
as
(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as totalnewvaccinations 
--,(totalnewvaccinations/population)*100
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
     on vac.location=dea.location
	 and vac.date=dea.date
where dea.continent is not null)


select*,totalnewvaccinations/population*100
from popvsvac


--TEMP TABLE
CREATE TABLE #POPULATIONVSVACCINE
(
Continent nvarchar(255),
LOCATION NVARCHAR(255),
date datetime,
population numeric,
new_vaccination numeric,
totalnewvaccination numeric)
insert into #POPULATIONVSVACCINE

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as totalnewvaccinations 
--,(totalnewvaccinations/population)*100
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
     on vac.location=dea.location
	 and vac.date=dea.date
--where dea.continent is not null)


select*,totalnewvaccination/population*100
from #POPULATIONVSVACCINE
ORDER BY 2,3


--CREATE A VIEW to store data for later visualisation

CREATE VIEW percent_population_vaccinated AS
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as totalnewvaccinations 
--,(totalnewvaccinations/population)*100
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
     on vac.location=dea.location
	 and vac.date=dea.date
where dea.continent is not null