USE Proj_Info430_Group9
go

-- CREATE tables
CREATE TABLE tblROLE
(RoleID INTEGER IDENTITY(1,1) primary key
,RoleName varchar(100) not null
,RoleDescr varchar(500) not null
)
go

CREATE TABLE tblEVENT_LOCATION
(EventLocationID INTEGER IDENTITY(1,1) primary key
,EventLocationName varchar(100) not null
,Street varchar(100)
,City varchar(100)
,[State] varchar(100)
,Country varchar(100)
,Zipcode varchar(20)
)
go

CREATE TABLE tblGENDER
(GenderID INTEGER IDENTITY(1,1) primary key
,GenderName varchar(20) not null
)
go

CREATE TABLE tblSTAGE
(StageID INTEGER IDENTITY(1,1) primary key
,StageName varchar(100) not null
)
go

CREATE TABLE tblPERFORMER_TYPE
(PerformerTypeID INTEGER IDENTITY(1,1) primary key
,PerformerTypeName varchar(100) not null
,PerformerTypeDesc varchar(500) not null
)
go

CREATE TABLE tblPERFORMER
(PerformerID INTEGER IDENTITY(1,1) primary key
,PerformerTypeID int FOREIGN KEY REFERENCES tblPERFORMER_TYPE (PerformerTypeID) not null
,PerformerName varchar(100) not null
)
go

CREATE TABLE tblEVENT
(EventID INTEGER IDENTITY(1,1) primary key
,EventTypeID int not null
,EventLocationID int not null
,EventName varchar(100)
,BeginDate date
,EndDate date
)
go

CREATE TABLE tblPERFORMANCE
(PerformanceID INTEGER IDENTITY(1,1) primary key
,EventID int FOREIGN KEY REFERENCES tblEVENT (EventID) not null
,PerformerID int FOREIGN KEY REFERENCES tblPERFORMER (PerformerID) not null
,StageID int FOREIGN KEY REFERENCES tblSTAGE (StageID) not null
,PerformStartTime time not null
,PerformEndTime time not null
)
go

CREATE TABLE tblCUSTOMER
(CustID INTEGER IDENTITY(1,1) primary key
,GenderID int FOREIGN KEY REFERENCES tblGENDER (GenderID) not null
,CustFname varchar(100) not null
,CustLname varchar(100) not null
,CustCity varchar(100) not null
,Zipcode varchar(20) not null
,CustDOB date not null
)
go


-- POPULATE tables
INSERT INTO tblPERFORMER_TYPE VALUES
('Comedian', 'A person who seeks to entertain an audience by making them laugh.'),
('Singer', 'A person who sings, especially professionally.'),
('Dancer', 'A person who dances or whose profession is dancing.'),
('Musician', 'A person who plays a musical instrument, especially as a profession, or is musically talented.'),
('Comedian', 'A person who seeks to entertain an audience by making them laugh.')

INSERT INTO tblSTAGE VALUES
('Stage 1'), ('Stage 2'), ('Stage 3'), ('Stage 4'), ('Stage 5')
go

INSERT INTO tblGENDER VALUES
('Male'), ('Female'), ('Trans man'), ('Trans woman'), ('Other')
go

INSERT INTO tblEVENT_LOCATION VALUES
('Location 1', '1 StreetAddress', 'CityName1', 'StateName1'),
('Location 2', '2 StreetAddress', 'CityName2', 'StateName2'),
('Location 3', '3 StreetAddress', 'CityName3', 'StateName3'),
('Location 4', '4 StreetAddress', 'CityName4', 'StateName4'),
('Location 5', '5 StreetAddress', 'CityName5', 'StateName5')
go


-- INSERT performer
CREATE PROCEDURE uspGetPerformerTypeID
@P_Type varchar(100),
@P_TypeID INT OUTPUT
AS
SET @P_TypeID = (SELECT PerformerTypeID FROM tblPERFORMER_TYPE WHERE PerformerTypeName = @P_Type)
go

CREATE PROCEDURE INSERT_PERFORMER
@Performer_Type varchar(100),
@Performer_Name varchar(100)
AS
DECLARE @PT_ID INT


EXEC uspGetPerformerTypeID
@P_Type = @Performer_Type,
@P_TypeID = @PT_ID OUTPUT
IF @PT_ID IS NULL
	BEGIN
        PRINT 'Hi...there is an error with @PT_ID being NULL'
        RAISERROR ('@PT_ID cannot be null', 11,1)
        RETURN
    END


BEGIN TRAN G1
INSERT INTO tblPERFORMER (PerformerTypeID, PerformerName)
VALUES (@PT_ID, @Performer_Name)
IF @@ERROR <> 0
    BEGIN
        PRINT 'Hey...there is an error up ahead and I am pulling over'
        ROLLBACK TRAN G1

    END
ELSE
    COMMIT TRAN G1

EXEC INSERT_PERFORMER
@Performer_Name = 'Liquid Stranger',
@Performer_Type = 'Musician'

EXEC INSERT_PERFORMER
@Performer_Name = 'Alison Wonderland',
@Performer_Type = 'Musician'

EXEC INSERT_PERFORMER
@Performer_Name = 'Excision',
@Performer_Type = 'Musician'
go


-- INSERT performance
CREATE PROCEDURE uspGetEventID
@E_Name varchar(100),
@Event_ID INT OUTPUT
AS
SET @Event_ID = (SELECT EventID FROM tblEVENT WHERE EventName = @E_Name)
go

CREATE PROCEDURE uspGetPerformerID
@P_Name varchar(100),
@Performer_ID INT OUTPUT
AS
SET @Performer_ID = (SELECT PerformerID FROM tblPERFORMER WHERE PerformerName = @P_Name)
go

CREATE PROCEDURE uspGetStageID
@S_Name varchar(100),
@Stage_ID INT OUTPUT
AS
SET @Stage_ID = (SELECT StageID FROM tblSTAGE WHERE StageName = @S_Name)
go

CREATE PROCEDURE INSERT_PERFORMANCE
@Event_Name varchar(100),
@Performer_Name varchar(100),
@Stage_Name varchar(100),
@Perform_StartTime time,
@Perform_EndTime time
AS
DECLARE @E_ID INT, @P_ID INT, @S_ID INT

EXEC uspGetEventID
@E_Name = @Event_Name,
@Event_ID = @E_ID OUTPUT
IF @E_ID IS NULL
	BEGIN
        PRINT 'Hi...there is an error with @E_ID being NULL'
        RAISERROR ('@E_ID cannot be null', 11,1)
        RETURN
    END

EXEC uspGetPerformerID
@P_Name = @Performer_Name,
@Performer_ID = @P_ID OUTPUT
IF @P_ID IS NULL
	BEGIN
        PRINT 'Hi...there is an error with @P_ID being NULL'
        RAISERROR ('@P_ID cannot be null', 11,1)
        RETURN
    END

EXEC uspGetStageID
@S_Name = @Stage_Name,
@Stage_ID = @S_ID OUTPUT
IF @S_ID IS NULL
	BEGIN
        PRINT 'Hi...there is an error with @S_ID being NULL'
        RAISERROR ('@S_ID cannot be null', 11,1)
        RETURN
    END

BEGIN TRAN G1
INSERT INTO tblPERFORMANCE (EventID, PerformerID, StageID, PerformStartTime, PerformEndTime)
VALUES (@E_ID, @P_ID, @S_ID, @Perform_StartTime, @Perform_EndTime)
IF @@ERROR <> 0
    BEGIN
        PRINT 'Hey...there is an error up ahead and I am pulling over'
        ROLLBACK TRAN G1

    END
ELSE
    COMMIT TRAN G1
go
-- **Need tblEVENT to be created in order to insert a performance with an EventID**


-- INSERT customer
CREATE PROCEDURE uspGetGenderID
@G_Name varchar(100),
@Gender_ID INT OUTPUT
AS
SET @Gender_ID = (SELECT GenderID FROM tblGENDER WHERE GenderName = @G_Name)
go

CREATE PROCEDURE INSERT_CUSTOMER
@Cust_FName varchar(100),
@Cust_LName varchar(100),
@Gender_Name varchar(100),
@Cust_City varchar(100),
@Cust_Zipcode varchar(20),
@Cust_BDay date
AS
DECLARE @G_ID INT

EXEC uspGetGenderID
@G_Name = @Gender_Name,
@Gender_ID = @G_ID OUTPUT
IF @G_ID IS NULL
	BEGIN
        PRINT 'Hi...there is an error with @G_ID being NULL'
        RAISERROR ('@G_ID cannot be null', 11,1)
        RETURN
    END

BEGIN TRAN G1
INSERT INTO tblCUSTOMER (GenderID, CustFName, CustLName, CustCity, Zipcode, CustDOB)
VALUES (@G_ID, @Cust_FName, @Cust_LName, @Cust_City, @Cust_Zipcode, @Cust_BDay)
IF @@ERROR <> 0
    BEGIN
        PRINT 'Hey...there is an error up ahead and I am pulling over'
        ROLLBACK TRAN G1

    END
ELSE
    COMMIT TRAN G1

EXEC INSERT_CUSTOMER
@Cust_FName = 'John',
@Cust_LName = 'Smith',
@Gender_Name = 'Male',
@Cust_City = 'Seattle',
@Cust_Zipcode = '98105',
@Cust_BDay = '09/01/1999'

EXEC INSERT_CUSTOMER
@Cust_FName = 'Jane',
@Cust_LName = 'Doe',
@Gender_Name = 'Female',
@Cust_City = 'Seattle',
@Cust_Zipcode = '98105',
@Cust_BDay = '09/15/1999'
