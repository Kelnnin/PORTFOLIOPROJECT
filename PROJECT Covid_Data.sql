--- SELECT COVID 19 DATA
USE Portfolio_Project;
SELECT * FROM Covid_Data

--- EXPLORATION DATA
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Data

--- DEATHS PERCENTAGE BY LOCATION
SELECT location, date, total_cases, total_deaths, 
	ROUND(((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100),2) AS Deaths_Percentage
FROM Covid_Data
ORDER BY 1,2

--- DEATHS PERCENTAGE IN MY COUNTRY
SELECT location, date, total_cases, total_deaths, 
	ROUND(((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100),2) AS Deaths_Percentage
FROM Covid_Data
WHERE location = 'Ecuador'
ORDER BY 1,2

--- POPULATIONS PERCENTAGE GOT COVID 19 BY LOCATION
SELECT location, date, total_cases, population,
	((CAST(total_cases AS FLOAT)/population)*100) AS Population_Percentage
FROM Covid_Data
ORDER BY 1,2

--- POPULATIONS PERCENTAGE GOT COVID 19 IN MY COUNTRY
SELECT location, date, total_cases, population,
	((CAST(total_cases AS FLOAT)/population)*100) AS Population_Percentage
FROM Covid_Data
WHERE location = 'Ecuador'
ORDER BY 1,2

--- COUNTRIES WITH HIGHEST INFECTION RATE COMPARATED TO POPULATION 
SELECT location, population, MAX(CAST(total_cases AS INT)) AS Highest_Infection,
	ROUND(MAX((CAST(total_cases AS INT)/population))*100,2) AS Population_Percentage
FROM Covid_Data
GROUP BY location, population
ORDER BY 4 DESC

--- COUNTRIES WITH HIGHEST DEATH COUNT   
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Highest_Death,
	ROUND(MAX((CAST(total_deaths AS INT)/population))*100,2) AS Population_Percentage
FROM Covid_Data
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

--- CONTINENTS WITH HIGHEST DEATH COUNT 
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Highest_Death
FROM Covid_Data
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--- TOTAL CASES
SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN 0
    ELSE ROUND((SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100, 2)
  END AS Deaths_Percentage
FROM Covid_Data
WHERE continent IS NOT NULL

--- TOTAL CASES PER DATE
SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN 0
    ELSE ROUND((SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100, 2)
  END AS Deaths_Percentage
FROM Covid_Data
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

--- TOTAL POPULATION VS VACCINATION
SELECT continent, location, date, population, new_vaccinations,
	SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS Total_Vaccinations
FROM Covid_Data
WHERE continent IS NOT NULL
ORDER BY 2,3

	--- CREATE CTE
WITH Pop_vs_Vac AS 
	(
		SELECT continent, location, date, population, new_vaccinations,
			SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS Total_Vaccinations
		FROM Covid_Data
		WHERE continent IS NOT NULL
		--- ORDER BY 2,3
	)
SELECT *, (Total_Vaccinations/population)*100 AS Total_Vaccinations_Percentage
FROM Pop_vs_Vac

--- VIEW FOR VISUALIZATION TABLEAU (PERCENTAGE POPULATION VACCINATIONS)
CREATE VIEW Visualization_Table AS
SELECT continent, location, date, population, new_vaccinations,
	SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS Total_Vaccinations
FROM Covid_Data
WHERE continent IS NOT NULL