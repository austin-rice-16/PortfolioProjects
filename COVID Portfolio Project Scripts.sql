Select * 
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 3,4

Select * 
From ProjectPortfolio..CovidVaccinations
order by 3,4

--Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract Covid in the USA
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) /CONVERT(float, total_cases))*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population 
Select Location, date, total_cases, population, (CONVERT(float, total_cases)/CONVERT(float, population))*100 as CasePercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases)/CONVERT(float, population))*100) as CasePercentage
From ProjectPortfolio..CovidDeaths
Group by location, population
order by 4 desc

--Looking at Countries with Most Deaths/Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc



--Breaking Things Down By Continent

--Showing continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/nullif(SUM(new_cases),0))*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not null
Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	order by 2,3


--USING CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
)

Select *, (RollingVaccinations/Population)*100 as VaccinatedPercentage
From PopvsVac


--USING TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null

Select *, (RollingVaccinations/Population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated