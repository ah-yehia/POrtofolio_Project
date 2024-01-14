select * 
from project_portofolio ..CovidDeath
order by 3 , 4


--select * 
--from project_portofolio ..CovidVaccination
--order by 3 , 4


--selecting the data we are going to use

Select location , date , total_cases , new_cases , total_deaths , population
From project_portofolio ..CovidDeath
Order by 1,2 

--Looking at Total Cases vs Total Deaths in Egypt


Select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
From project_portofolio ..CovidDeath
Where location like '%Egypt%'
Order by 1,2 


--Looking at Total Cases vs Population in Egypt


Select location , date , total_cases , population ,   (total_cases/population)*100 as Cases_Percentage
From project_portofolio ..CovidDeath
Where location like '%Egypt%'
Order by 1,2 

--looking at countries with highest infection rate compared to population


Select location ,Population ,  Max (total_cases) as HighestInfectionRate ,   Max((total_cases/population)*100) as Cases_Percentage
From project_portofolio ..CovidDeath
Group by location ,Population
Order by Cases_Percentage desc

--Showing countries with highest death count per Population

Select location,  Max (cast (total_deaths as int)) as HighestDeathRate 
from Project_Portofolio .. CovidDeath
where continent is not null
Group by location
Order by HighestDeathRate desc

--Breaking things down into continents

Select location,  Max (cast (total_deaths as int)) as HighestDeathRate 
from Project_Portofolio .. CovidDeath
where continent is  null
Group by location
Order by HighestDeathRate desc


--Showing continents with highest Death count per population

	Select continent,  Max (cast (total_deaths as int)/population) as DeathRatePerPopulation 
	from Project_Portofolio .. CovidDeath
	where continent is not null
	Group by continent
	Order by DeathRatePerPopulation desc

--Global Numbers


Select   sum(new_cases) as NewCasesSum, sum(cast (new_deaths as int)) as NewDeathsSum , sum(cast (new_deaths as int)) / sum (new_cases)*100 as DeathsPercentage
From project_portofolio ..CovidDeath
where continent is not null
--Group by date
Order by 1,2 


--using CTE


with popvsVac(continent, location , date , population , New_vaccinations ,RollingPeopleVaccinated )
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
, sum (convert (int ,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location , dea.date)
as RollingPeopleVaccinate--(RollingPeopleVaccinated/population)*100
from Project_Portofolio..CovidDeath dea
join Project_Portofolio..CovidVaccination vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select * , ((RollingPeopleVaccinated/population)*100) from popvsVac 




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

