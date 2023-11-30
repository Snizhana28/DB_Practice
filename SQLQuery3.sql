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
    [Name] NVARCHAR(20) NOT NULL,
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

CREATE TABLE [Sponsors] (
    [Id] INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE [Donations] (
    [Id] INT IDENTITY PRIMARY KEY,
    [Amount] MONEY NOT NULL,
    [Date] DATE DEFAULT GETDATE(),
    [DepartmentId] INT NOT NULL REFERENCES Departments(Id),
    [SponsorId] INT NOT NULL REFERENCES Sponsors(Id),

    constraint chk_Amount CHECK (Amount >= 0),

);

INSERT INTO [Departments] ([Building], [Name]) VALUES
(1,'General Surgery'),
(2,'Cardiology'),
(3,'Neurology'),
(4,'Gastroenterology'),
(5,'Oncology');

INSERT INTO [Doctors] ([Name], [Premium], [Salary], [Surname]) VALUES
('Joshua', 0, 2000, 'Bell'),
('Thomas', 700, 12000, 'Gerada'),
('Davis', 600, 11000, 'Anthony');

INSERT INTO [Examinations] ([Name]) VALUES
('Blood Test'),
('X-ray'),
('MRI'),
('lung examination');

INSERT INTO [Wards] ([Name], [Places], [DepartmentId]) VALUES
('Ward 101', 10, 1),
('Ward 201', 15, 2),
('Ward 301', 20, 3),
('Ward 401', 200, 4),
('Ward 501', 150, 5);


INSERT INTO [DoctorsExaminations] ([DoctorId], [ExaminationId], [WardId], [StartTime], [EndTime])
VALUES
(1, 1, 1, '08:30', '10:00'),
(2, 2, 2, '10:30', '12:00'),
(3, 3, 3, '13:30', '15:00');

INSERT INTO [Sponsors] ([Name]) VALUES
('ABC Company'),
('XYZ Foundation'),
('Umbrella Corporation');

INSERT INTO [Donations] (Amount, DepartmentId, SponsorId) VALUES
(10000, 1, 1),
(150000, 2, 2),
(80000, 3, 3);

-- 1. ������� ����� �������, �� ����������� � ���� � ������, �� � �������� �[Cardiology]�.
SELECT D2.Name AS DepartmentName
FROM [Departments] D1
JOIN [Departments] D2 ON D1.Building = D2.Building
WHERE D1.Name = 'Cardiology';

-- 2. ������� ����� �������, �� ����������� � ���� � ������, �� � �������� �[Gastroenterology]� �� �[General Surgery]�.
SELECT D.Name AS DepartmentName
FROM [Departments] D
JOIN [Departments] D2 ON D.Building = D2.Building
WHERE D2.Name IN ('Gastroenterology', 'General Surgery');

-- 3. ������� ����� ��������, ��� �������� �������� ������������.
SELECT TOP 1 D.Name AS DepartmentName
FROM [Departments] D
JOIN [Donations] DN ON D.Id = DN.DepartmentId
GROUP BY D.Name
ORDER BY SUM(DN.Amount) ASC;

-- 4. ������� ������� �����, ������ ���� �����, �� � ����� �[Thomas Gerada]�.
SELECT D.Surname
FROM [Doctors] D
WHERE D.Salary > (SELECT Salary FROM [Doctors] WHERE Surname = 'Thomas Gerada');

-- 5. ������� ����� �����, ������� ���� �����, �� ������� ������� � ������� �������� �[Microbiology]�.
SELECT W.Name AS WardName, W.Places
FROM [Wards] W
JOIN [Departments] D ON W.DepartmentId = D.Id
WHERE D.Name = 'Microbiology' AND W.Places > (SELECT AVG(Places) FROM [Wards] WHERE DepartmentId = D.Id);

-- 6. ������� ���� ����� �����, �������� ���� (���� ������ �� ��������) ����������� ���� �� �� 100 �������� ����� �[Anthony Davis]�.
SELECT D.Name + ' ' + D.Surname AS DoctorName
FROM [Doctors] D
WHERE D.Salary + D.Premium > (SELECT Salary + Premium FROM [Doctors] WHERE Surname = 'Davis' AND Name = 'Anthony') + 100;

-- 7. ������� ����� �������, � ���� ��������� ���������� ���� [Joshua Bell].
SELECT D.Name AS DepartmentName
FROM [Departments] D
JOIN [Wards] W ON D.Id = W.DepartmentId
JOIN [DoctorsExaminations] DE ON W.Id = DE.WardId
JOIN [Doctors] DO ON DE.DoctorId = DO.Id
WHERE DO.Name = 'Joshua' AND DO.Surname = 'Bell';

-- 8. ������� ����� ��������, �� �� ������ ������������� ��������� �[Neurology]� �� �[Oncology]�.
SELECT S.Name AS SponsorName
FROM [Sponsors] S
WHERE NOT EXISTS (
    SELECT 1
    FROM [Donations] DN
    JOIN [Departments] D ON DN.DepartmentId = D.Id
    WHERE S.Id = DN.SponsorId AND D.Name IN ('Neurology', 'Oncology')
);

-- 9. ������� ������� �����, �� ��������� ���������� � ����� � 12:00 �� 15:00.
SELECT DISTINCT D.Surname
FROM [Doctors] D
JOIN [DoctorsExaminations] DE ON D.Id = DE.DoctorId
WHERE DE.StartTime BETWEEN '12:00' AND '15:00';