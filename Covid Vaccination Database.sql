select *
from PortfolioProject..CovidDeaths$
where continent is null
order by 3,4

select *
from PortfolioProject..CovidVaccination$
order by 3,4

select Location,Date,total_cases,new_cases, total_deaths ,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Show death percentage
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1,2

-- SHowing countries highest death counts per Population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by	totaldeathcount desc

-- SHowing continents highest death counts per Population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by	totaldeathcount desc


-- Global Numbers
SELECT date,SUM(new_cases) AS Total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,CASE WHEN SUM(new_cases) = 0 THEN NULL
ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--Total cases vs Total Deaths
 
SELECT SUM(new_cases) AS Total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,CASE WHEN SUM(new_cases) = 0 THEN NULL
ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Total death as comapare to population

SELECT sum(new_cases) as newCase,sum(population) AS Population,SUM(CAST(new_deaths AS INT)) AS total_deaths,CASE WHEN SUM(new_cases) = 0 THEN NULL
ELSE SUM(CAST(new_deaths AS INT)) / sum(Population) * 100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Total death of continent as comapare to population
SELECT continent, sum(new_cases) as newCase,sum(population) AS Population,SUM(CAST(new_deaths AS INT)) AS total_deaths,CASE WHEN SUM(new_cases) = 0 THEN NULL
ELSE SUM(CAST(new_deaths AS INT)) / sum(Population) * 100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage desc

-- Total death of country as comapare to population
SELECT Location, sum(new_cases) as newCase,sum(population) AS Population,SUM(CAST(new_deaths AS INT)) AS total_deaths,CASE WHEN SUM(new_cases) = 0 THEN NULL
ELSE SUM(CAST(new_deaths AS INT)) / sum(Population) * 100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY DeathPercentage 

--VaccinationJoin--

 
-- Looking at total population as Vaccine

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

--Use CTE --
with PopvsVac (continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;
)
Select *, (RollingPeopleVaccinated/Population)*100 as People_vacii_Percent
from PopvsVac

--Temp Table --
Drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into  #PercentPopulationVaccinated

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;

Select *, (RollingPeopleVaccinated/Population)*100 as People_vacii_Percent
from  #PercentPopulationVaccinated


--Creating a view to store data for alter data visualizations

create view PercentPopulationVaccinated as

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;

Select *
from PercentPopulationVaccinated
