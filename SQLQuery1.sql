create database Hospital
go
use Hospital
go

CREATE TABLE [Departments] (
  [Id] INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(100) NOT NULL UNIQUE,
);

CREATE TABLE [Doctors](
  [Id] INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(MAX) NOT NULL,
  [Premium] MONEY NOT NULL DEFAULT 0,
  [Salary] MONEY NOT NULL,
  [Surname] NVARCHAR(MAX) NOT NULL,

  constraint chk_Salary CHECK (Salary > 0),
);

CREATE TABLE [DoctorsSpecializations] (
    Id INT IDENTITY PRIMARY KEY,
    DoctorId INT NOT NULL REFERENCES Doctors(Id),
    SpecializationId INT NOT NULL REFERENCES Specializations(Id)
);

CREATE TABLE [Donations] (
    [Id] INT IDENTITY PRIMARY KEY,
    [Amount] MONEY NOT NULL,
    [Date] DATE DEFAULT GETDATE(),
    [DepartmentId] INT NOT NULL REFERENCES Departments(Id),
    [SponsorId] INT NOT NULL REFERENCES Sponsors(Id),

    constraint chk_Amount CHECK (Amount >= 0),

);

CREATE TABLE [Specializations] (
    [Id] INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE [Sponsors] (
    [Id] INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE [Vacations] (
    [Id] INT IDENTITY PRIMARY KEY,
    [EndDate] DATE NOT NULL,
    [StartDate] DATE NOT NULL,
    [DoctorId] INT NOT NULL REFERENCES Doctors(Id),

	constraint chk_EndDate CHECK (EndDate > StartDate),

);

CREATE TABLE [Wards] (
    [Id] INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(20) UNIQUE NOT NULL,
    [DepartmentId] INT NOT NULL REFERENCES Departments(Id)
);

--INSERT

INSERT INTO [Departments] ([Name]) VALUES
('Intensive Treatment'),
('Gynecology'),
('Traumatology');

 
INSERT INTO [Doctors] ([Name], Premium, Salary, Surname) VALUES
('Ivan', 0, 2000, 'Petrov'),
('Olga', 700, 12000, 'Ivanova'),
('Helen', 600, 11000, 'Williams');

INSERT INTO [Specializations] ([Name]) VALUES
('Surgeon'),
('Gynecologist'),
('Traumatologist');

INSERT INTO [DoctorsSpecializations] (DoctorId, SpecializationId) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO [Sponsors] ([Name]) VALUES
('ABC Company'),
('XYZ Foundation'),
('Umbrella Corporation');

INSERT INTO [Donations] (Amount, DepartmentId, SponsorId) VALUES
(10000, 1, 1),
(150000, 2, 2),
(80000, 3, 3);

INSERT INTO [Vacations] (EndDate, StartDate, DoctorId) VALUES
('2023-12-31', '2023-12-20', 1),
('2023-11-15', '2023-11-01', 2),
('2024-01-15', '2023-12-25', 3);

INSERT INTO Wards ([Name], DepartmentId) VALUES
('Ward 101', 1),
('Ward 201', 2),
('Ward 301', 3);

--SELECT

-- ¬ивести повн≥ ≥мена л≥кар≥в та њх спец≥ал≥зац≥њ.
select Doctors.Name + ' ' + Doctors.Surname AS 'Doctor Name', Specializations.Name AS 'Specialization'
from [Doctors]
join DoctorsSpecializations ON [Doctors].Id = [DoctorsSpecializations].DoctorId
join Specializations ON [DoctorsSpecializations].SpecializationId = Specializations.Id;

-- ¬ивести пр≥звища та зарплати (сума ставки та надбавки) л≥кар≥в, €к≥ не перебувають у в≥дпустц≥.
select Surname, Salary + Premium AS 'Total Salary'
from [Doctors]
where Id NOT IN (select DoctorId from Vacations where GETDATE() BETWEEN StartDate AND EndDate);

-- ¬ивести назви палат, що знаход€тьс€ у в≥дд≥ленн≥ УIntensive TreatmentФ.
select Wards.Name 
from Wards
join Departments ON Wards.DepartmentId = Departments.Id
where Departments.Name = 'Intensive Treatment';

-- ¬ивести назви в≥дд≥лень без повторень, що спонсоруютьс€ компан≥Їю УUmbrella CorporationФ.
select distinct Departments.Name
from Departments 
join Donations ON Departments.Id = Donations.DepartmentId
join Sponsors ON  Donations.SponsorId = SponsorId
where Sponsors.Name = 'Umbrella Corporation';

-- ¬ивести вс≥ пожертвуванн€ за останн≥й м≥с€ць у вигл€д≥: в≥дд≥ленн€, спонсор, сума пожертвуванн€, дата пожертвуванн€.
select Departments.Name AS 'Department', Sponsors.Name AS 'Sponsors', Amount AS 'Donation Amount', Date AS 'Donation Date'
from Donations
join Departments ON Donations.DepartmentId = Departments.Id
join Sponsors ON  Donations.SponsorId = SponsorId
where Date >= DATEADD(month, -1, GETDATE());

-- ¬ивести назви палат в≥дд≥лень, у €ких проводить обстеженн€ л≥кар УHelen WilliamsФ.
select Wards.Name AS 'Wards Name', Departments.Name AS'Departments Name'
from Wards
join Departments ON Wards.DepartmentId = Departments.Id
join Doctors ON  Departments.Id = Doctors.Id
where Doctors.Name + ' ' + Doctors.Surname = 'Helen Williams';

-- ¬ивести назви в≥дд≥лень, €к≥ отримували пожертвуванн€ у розм≥р≥ б≥льше 100000, ≥з зазначенн€м њхн≥х л≥кар≥в.
select distinct Departments.Name AS 'Departments Name', Doctors.Name + ' ' + Doctors.Surname AS 'Doctors'
from Departments
join Donations ON departments.Id = Donations.DepartmentId
join Doctors ON Departments.Id = Doctors.Id
where Amount > 100000;

-- ¬ивести назви в≥дд≥лень, у €ких Ї л≥кар≥, €к≥ не отримують надбавки.
select distinct  Departments.Name AS 'Departments Name'
from Departments
join Doctors ON Departments.Id = Doctors.Id
where Doctors.Premium = 0;



