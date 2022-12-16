/*
Covid 19 Data Exploration from 2020 - 2022
Dataset Link   : https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqa05UQndBSjJJLVA0SE9RNVh2ZnliNmw5ZzFuQXxBQ3Jtc0tsR2JoeTdHSThZOTE0OFhIREZvaTFWX1Z0SmRnV1hoM0hTWlVlcmF4a252blNsaDZURk1fenlXb090bEVOTjZWa3BMMjZybHlnM0JfRDByLUhBcW9nZFB5ZXlNVWVueVVyRkZfUmxCYUVaZERqcnBQZw&q=https%3A%2F%2Fourworldindata.org%2Fcovid-deaths&v=qfyynHBFOsM
SQL Skills used: DML, Group by, Order by, Aggregate Functions, Converting Data Types, Windows Functions,
                 Joins, CTE's, Creating Views, 
*/

select * from CovidPorfolioProject..Coviddeaths
Where continent is not null 
order by 3,4
select * from CovidPorfolioProject..Covidvaccinations
Where continent is not null 
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPorfolioProject..Coviddeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
-- Calculating the percentage of people death who has disease

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPorfolioProject..Coviddeaths
where continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 
as PercentPopulationInfected
From CovidPorfolioProject..Coviddeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPorfolioProject..Coviddeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPorfolioProject..Coviddeaths
--Where location like '%states%'
Where continent is not null 
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPorfolioProject..Coviddeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPorfolioProject..Coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPorfolioProject..Coviddeaths dea
Join CovidPorfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPorfolioProject..Coviddeaths dea
Join CovidPorfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From CovidPorfolioProject..Coviddeaths dea
Join CovidPorfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- Select view
select * from PercentPopulationVaccinated