SELECT * FROM PortfolioProject.DBO.CovidDeaths


-- Looking at the probability of dying if contracted COVID 19
SELECT location, date, total_cases, total_deaths, (total_deaths*100/total_cases) AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at the probability of dying in India
SELECT location, date, total_cases, total_deaths, (total_deaths*100/total_cases) AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location='India'
ORDER BY 1,2

-- %age of people that got COVID
SELECT location, date, population, total_cases, (total_cases*100/population) AS TotalCasePercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location='United States'
ORDER BY 1,2


-- Countries with highest infection rate at present
SELECT location, population, max(total_cases) AS PresentTotalCase, max(total_cases*100/population) AS TotalCasePercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL  --If continent is null then continent's name is present in location column. But we only want countries, so we will put the condition where continent column is not null
GROUP BY location, population
ORDER BY TotalCasePercentage DESC

-- Countries with highest deaths 
SELECT location,max(CAST(total_deaths AS int)) AS DeathsNumber
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathsNumber DESC

-- continents with highest death counts
SELECT location, max(CAST(total_deaths AS int)) AS DeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World','Upper middle income','High income','Lower middle income','Low income','International')
GROUP BY location
ORDER BY DeathCount DESC


-- GLOBAL DATA

-- Death Percentage each day across the globe
SELECT date,sum(new_cases) as TotalCases ,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))*100/sum(new_cases)) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

--total death percentage across the globe
SELECT sum(new_cases) as TotalCases ,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))*100/sum(new_cases)) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date

--Explore the vaccination data

-- Look at the new vaccinations each day for each country
SELECT deaths.continent, deaths.location,deaths.date,population,new_vaccinations FROM 
PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccination As vac
ON deaths.location=vac.location
	AND deaths.date=vac.date
ORDER BY 2,3

-- Total Vaccinations for each country with new vaccinations each day
SELECT deaths.continent, deaths.location,deaths.date,population,new_vaccinations,SUM(CONVERT(BIGINT,new_vaccinations)) OVER (PARTITION BY deaths.location)  AS TotalVaccination 
FROM 
PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccination As vac
ON deaths.location=vac.location
	AND deaths.date=vac.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3


-- Total Vaccinations till date for each country with new vaccinations each day
SELECT deaths.continent, deaths.location,deaths.date,population,new_vaccinations,SUM(CONVERT(BIGINT,new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.date)  AS TotalVaccination 
FROM 
PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccination As vac
ON deaths.location=vac.location
	AND deaths.date=vac.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

-- Total vaccinated people percentage for each country using CTE

WITH Vaccination_CTE(Continent,Location, Date, Population,People_Vaccinated)
AS
(SELECT deaths.continent, deaths.location,deaths.date,population,CONVERT(bigint,people_vaccinated)
FROM 
PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccination As vac
ON deaths.location=vac.location
	AND deaths.date=vac.date
WHERE deaths.continent IS NOT NULL
)

SELECT Location,Population,max(People_Vaccinated) AS TotalVaccinated, (max(People_Vaccinated)*100/Population) AS PercentageVaccianted
FROM Vaccination_CTE
GROUP BY Location,Population
ORDER BY 1 


select location,date,people_fully_vaccinated from PortfolioProject..CovidVaccination
order by 1,2

-- Getting the percentage of fully vaccinated people using temporary table or temp table

DROP TABLE IF EXISTS #Vaccinaton_Table
CREATE TABLE #Vaccinaton_Table
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
people_fully_vaccinated numeric)


INSERT INTO #Vaccinaton_Table
SELECT deaths.continent, deaths.location,deaths.date,population,CONVERT(bigint,people_fully_vaccinated)
FROM 
PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccination As vac
ON deaths.location=vac.location
	AND deaths.date=vac.date
WHERE deaths.continent IS NOT NULL


SELECT location,population, max(people_fully_vaccinated) AS Fully_Vaccinated_People, (max(people_fully_vaccinated)*100/population) AS Percentage_Fully_Vaccinated
FROM #Vaccinaton_Table
GROUP BY location,population
ORDER BY 1

-- We can create a view to access a table created for Fully Vaccinated People

CREATE VIEW PercentFullyVaccinated AS
SELECT deaths.continent, deaths.location,deaths.date,population,CONVERT(bigint,people_fully_vaccinated) AS people_fully_vaccinated
FROM 
PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccination As vac
ON deaths.location=vac.location
	AND deaths.date=vac.date
WHERE deaths.continent IS NOT NULL

SELECT * FROM PercentFullyVaccinated
ORDER BY 2,3


