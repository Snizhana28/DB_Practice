create database Hospital
go
use Hospital
go

CREATE TABLE [Departments] (
  [Id] INT PRIMARY KEY IDENTITY,
  [Building] INT NOT NULL,
  [Name] NVARCHAR(100) NOT NULL UNIQUE,

  constraint chk_Building CHECK (Building >= 1 AND Building <= 5),
);

CREATE TABLE [Doctors](
  [Id] INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(MAX) NOT NULL,
  [Premium] MONEY NOT NULL DEFAULT 0,
  [Salary] MONEY NOT NULL,
  [Surname] NVARCHAR(MAX) NOT NULL,

  constraint chk_Salary CHECK (Salary > 0),
);

CREATE TABLE [Examinations] (
    [Id] INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL UNIQUE,
);

CREATE TABLE [Wards] (
    [Id] INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(20) UNIQUE NOT NULL,
	[Places] INT NOT NULL,
    [DepartmentId] INT NOT NULL REFERENCES Departments(Id),

	constraint chk_Places CHECK (Places >= 1),
);

CREATE TABLE [DoctorsExaminations] (
    [Id] INT PRIMARY KEY IDENTITY,
    [EndTime] TIME NOT NULL,
    [StartTime] TIME NOT NULL,
    [DoctorId] INT NOT NULL REFERENCES Doctors(Id),
    [ExaminationId] INT NOT NULL REFERENCES Examinations(Id),
    [WardId] INT NOT NULL REFERENCES Wards(Id),

	constraint chk_EndTime CHECK (EndTime > StartTime),
	constraint chk_StartTime CHECK (StartTime BETWEEN '08:00' AND '18:00'),
);

INSERT INTO [Departments] ([Building], [Name]) VALUES
(1,'Cardiology'),
(2,'Orthopedics'),
(3,'Pediatrics'),
(4,'Stomatology'),
(5,'Oncology');

INSERT INTO [Doctors] ([Name], [Premium], [Salary], [Surname]) VALUES
('Ivan', 0, 2000, 'Petrov'),
('Olga', 700, 12000, 'Ivanova'),
('Helen', 600, 11000, 'Williams');

INSERT INTO [Examinations] ([Name]) VALUES
('Blood Test'),
('X-ray'),
('MRI'),
('lung examination');

INSERT INTO [Wards] ([Name], [Places], [DepartmentId]) VALUES
('Ward 101', 10, 1),
('Ward 201', 15, 2),
('Ward 301', 200, 3);

INSERT INTO [DoctorsExaminations] ([DoctorId], [ExaminationId], [WardId], [StartTime], [EndTime])
VALUES
(1, 1, 1, '08:30', '10:00'),
(2, 2, 2, '10:30', '12:00'),
(3, 3, 3, '13:30', '15:00');

-- 1. Вивести кількість палат, місткість яких більша за 10.
SELECT COUNT(*) AS [NumberOfWards]
FROM [Wards]
WHERE [Places] > 10;

-- 2. Вивести назви корпусів та кількість палат у кожному з них.
SELECT [D].[Building], COUNT([W].[Id]) AS [NumberOfWards]
FROM [Departments] [D]
JOIN [Wards] [W] ON [D].[Id] = [W].[DepartmentId]
GROUP BY [D].[Building];

-- 3. Вивести назви відділень та кількість палат у кожному з них.
SELECT [D].[Name] AS [DepartmentName], COUNT([W].[Id]) AS [NumberOfWards]
FROM [Departments] [D]
JOIN [Wards] [W] ON [D].[Id] = [W].[DepartmentId]
GROUP BY [D].[Name];

-- 4. Вивести назви відділень та сумарну надбавку лікарів у кожному з них.
SELECT [D].[Name] AS [DepartmentName], SUM([DO].[Premium]) AS [TotalPremium]
FROM [Departments] [D]
JOIN [Wards] [W] ON [D].[Id] = [W].[DepartmentId]
JOIN [Doctors] [DO] ON [D].[Id] = [DO].[Id]
GROUP BY [D].[Name];

-- 5. Вивести назви відділень, у яких проводять обстеження 5 та більше лікарів.
SELECT [D].[Name] AS [DepartmentName], COUNT([DO].[Id]) AS [NumberOfDoctors]
FROM [Departments] [D]
JOIN [Wards] [W] ON [D].[Id] = [W].[DepartmentId]
JOIN [Doctors] [DO] ON [D].[Id] = [DO].[Id]
JOIN [DoctorsExaminations] [DE] ON [DO].[Id] = [DE].[DoctorId]
GROUP BY [D].[Name]
HAVING COUNT([DO].[Id]) >= 5;

-- 6. Вивести кількість лікарів та їх сумарну зарплату (сума ставки та надбавки).
SELECT COUNT(*) AS [NumberOfDoctors], SUM([DO].[Salary] + [DO].[Premium]) AS [TotalSalary]
FROM [Doctors] [DO];

-- 7. Вивести середню зарплату (сума ставки та надбавки) лікарів.
SELECT AVG([DO].[Salary] + [DO].[Premium]) AS [AverageSalary]
FROM [Doctors] [DO];

-- 8. Вивести назви палат із мінімальною місткістю.
SELECT [Name] AS [WardName], [Places]
FROM [Wards]
WHERE [Places] = (SELECT MIN([Places]) FROM [Wards]);

-- 9. Вивести в яких із корпусів 1, 6, 7 та 8, сумарна кількість місць у палатах перевищує 100.
SELECT [D].[Building], SUM([W].[Places]) AS [TotalPlaces]
FROM [Departments] [D]
JOIN [Wards] [W] ON [D].[Id] = [W].[DepartmentId]
WHERE [D].[Building] IN (1, 6, 7, 8)
GROUP BY [D].[Building]
HAVING SUM([W].[Places]) > 100;