
--Checking if the tables were brought in correctly (commented the commands after checking)

Select *
From [Covid Portfolio Project]..['Covid Deaths$']
Where continent is not null
order by 3,4

--Select *
--From [Covid Portfolio Project]..['Covid Vaccinations$']
--order by 3,4

--looking at specific columns only in the covid deaths table

Select location, date, total_cases, new_cases, total_deaths, population
From [Covid Portfolio Project]..['Covid Deaths$']
order by 1,2

--Comparing total cases vs total deaths, showing the percentage of chance of death in your country if infected. 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..['Covid Deaths$']
Where location like '%states'
order by 1,2

--Comparing total cases vs population, showing the percentage of population infected
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From [Covid Portfolio Project]..['Covid Deaths$']
Where location like '%states'
order by 1,2

--Countries with the highest infection rate compared to the population. "Max" is used to only look at the highest value from that country. 
Select location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as InfectionPercentage
From [Covid Portfolio Project]..['Covid Deaths$']
--Where location like '%states'
Group by Location, population
order by InfectionPercentage desc

--Countries with the highest death count per population. The total_deaths data needs to be changes from the nvarchar type to the integer type, hence cast as int
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Covid Portfolio Project]..['Covid Deaths$']
--Where location like '%states'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--SHOWING THINGS BY CONTINENT
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Covid Portfolio Project]..['Covid Deaths$']
--Where location like '%states'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers total as of 4/23/2022
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..['Covid Deaths$']
--Where location like '%states'
Where continent is not null
--Group by date
order by 1,2


--Global numbers by date as of 4/23/2022
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..['Covid Deaths$']
--Where location like '%states'
Where continent is not null
Group by date
order by 1,2


--Using the covid vaccination data, joining the deaths and vaccination tables on date and location to compare total population vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated, (SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date))/dea.population*100 as PercentPopVaccinated
From [Covid Portfolio Project]..['Covid Deaths$'] dea
Join [Covid Portfolio Project]..['Covid Vaccinations$'] vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



--Creating a view to store data for future visualizations 
DROP View if exists PercentPopVaccinated

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated, (SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date))/dea.population*100 as PercentPopVaccinated
From [Covid Portfolio Project]..['Covid Deaths$'] dea
Join [Covid Portfolio Project]..['Covid Vaccinations$'] vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3