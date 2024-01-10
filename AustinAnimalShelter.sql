USE ProjectPortfolio
---Quick look at the data
SELECT *
FROM ShelterIntakes

SELECT *
FROM ShelterOutComes

---Standardizing Date Columns
ALTER TABLE ShelterIntakes
ALTER COLUMN DateTime DATE

ALTER TABLE ShelterIntakes
DROP COLUMN MonthYear

ALTER TABLE ShelterOutcomes
ALTER COLUMN DateTime DATE

ALTER TABLE ShelterOutcomes
DROP COLUMN MonthYear

---What types of animals are included?
SELECT COUNT(*) AS Count, [Animal Type]
FROM ShelterIntakes
GROUP BY [Animal Type]
ORDER BY Count DESC
--As expected, most of the data is dogs or cats. For the purposes of this exploratory analysis, I will be excluding any other type of animal.


---What age group is most likely to be strays?
SELECT COUNT(*) AS NumberOfStrays
, CASE WHEN [Age upon Intake] LIKE '%month%' OR [Age upon Intake] LIKE '%week%' OR [Age upon Intake] LIKE '%day%' THEN 'Under 1 Year'
	   WHEN [Age upon Intake] = '1 year' OR [Age upon Intake] = '2 years' OR [Age upon Intake] = '3 years' THEN '1-3 Years Old'
	   WHEN [Age upon Intake] = '4 years' OR [Age upon Intake] = '5 years' OR [Age upon Intake] = '6 years' THEN '4-6 Years Old'
	   WHEN [Age upon Intake] = '7 years' OR [Age upon Intake] = '8 years' OR [Age upon Intake] = '9 years' THEN '7-9 Years Old'
	   ELSE '10+ Years Old'
	   END AS AgeGroup
FROM ShelterIntakes
WHERE [Intake Type] = 'Stray' AND ([Animal Type] = 'Cat' OR [Animal Type] = 'Dog')
GROUP BY CASE WHEN [Age upon Intake] LIKE '%month%' OR [Age upon Intake] LIKE '%week%' OR [Age upon Intake] LIKE '%day%' THEN 'Under 1 Year'
	   WHEN [Age upon Intake] = '1 year' OR [Age upon Intake] = '2 years' OR [Age upon Intake] = '3 years' THEN '1-3 Years Old'
	   WHEN [Age upon Intake] = '4 years' OR [Age upon Intake] = '5 years' OR [Age upon Intake] = '6 years' THEN '4-6 Years Old'
	   WHEN [Age upon Intake] = '7 years' OR [Age upon Intake] = '8 years' OR [Age upon Intake] = '9 years' THEN '7-9 Years Old'
	   ELSE '10+ Years Old'
	   END
ORDER BY NumberOfStrays DESC

--Of the ~86,000 strays recorded in this shelter, ~73,000 are 3 years or younger and almost half are under 1 year.


---Joining shelter intakes with shelter outcomes to find out this shelter's adoption vs euthanasia statistics
SELECT COUNT(*) AS NumberOfAnimals, outcome.[Outcome Type]
FROM ShelterIntakes intake
JOIN ShelterOutComes outcome
ON intake.[Animal ID] = outcome.[Animal ID]
WHERE intake.[Animal Type] = 'Dog' OR intake.[Animal Type] = 'Cat'
GROUP BY [Outcome Type]
ORDER BY NumberOfAnimals DESC

--Fortunately, at this shelter it is about 17 times more likely that an animal will be adopted versus being put down.
--Only around 2-3 percent of animals at this shelter get euthanized. 
--What kinds of animals should be pushed harder for adoption?

SELECT outcome.[Age upon Outcome], intake.[Animal Type], outcome.Breed, COUNT(*) AS NumberOfAnimals
FROM ShelterIntakes intake
JOIN ShelterOutComes outcome
ON intake.[Animal ID] = outcome.[Animal ID]
WHERE (intake.[Animal Type] = 'Dog' OR intake.[Animal Type] = 'Cat') AND outcome.[Outcome Type] = 'Euthanasia'
GROUP BY outcome.Breed, intake.[Animal Type], outcome.[Age upon Outcome]
ORDER BY NumberOfAnimals DESC

--Based off this, the shelter should provide more resources on getting domestic shorthair cats and pit bull dogs adopted. 
--Additionally, the younger animals seem to be more likely to be put down.