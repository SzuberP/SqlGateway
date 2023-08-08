/* 

Stored Procedures for Gateway DB 
Author: piotr.szubert@jacobs.com | GIS Specialist
Global Delivery Center | Kraków | Poland

*/ 

-- Adding new infrastructure user only if not already in DB
CREATE TRIGGER AddInfrastructureUser_00
ON FormsTracker
FOR UPDATE AS
BEGIN
SET NOCOUNT ON;
	IF UPDATE (approved)
		BEGIN		

		DECLARE @UserEmail nvarchar(50)
		DECLARE @UserProject nvarchar(50)
		DECLARE @PersonID TABLE (ID int)

		SET @UserEmail = (SELECT Email FROM inserted)
		SET @UserProject = (SELECT Project FROM inserted)
		

		-- When user is already in DB adn we just add new project connection
		IF @UserEmail NOT IN (SELECT Email FROM People_Details)
			BEGIN
			
			INSERT INTO People_Details (Title, HomeOrganisation, Email) 
			OUTPUT inserted.PersonDetailsID INTO @PersonID -- we need to store auto generated identity into table variable
			SELECT 
				CONCAT(FirstName, ' ', Surname), -- TITLE column
				(SELECT HomeOrgID FROM Home_Organisations WHERE HomeOrganisationName = (SELECT SUBSTRING(value, 1, len(value) - 4 ) FROM string_split(Email, '@', 1) WHERE ordinal = 2)), -- home organisation extracted from email
				Email
			FROM inserted;
			
			
			INSERT INTO PersonProject (PersonID, ProjectID, StartDay)
			SELECT
				(SELECT ID FROM @PersonID),
				(SELECT ProjectID FROM Projects WHERE ProjectName = @UserProject),
				
			FROM inserted
			END;	

		ELSE			
			BEGIN

			PRINT 'ELSE'
			
			INSERT INTO PersonProject (PersonID, ProjectID, StartDay)
			SELECT 
				(SELECT PersonDetailsID FROM People_Details WHERE Email = @UserEmail),
				(SELECT ProjectID FROM Projects WHERE ProjectName = @UserProject),
				CAST(GETDATE() AS DATE)				
			FROM inserted
			END;

		END
END 
GO

-- Adding Home org if needed
CREATE TRIGGER CheckAndAddHomeOrg_00
ON FormsTracker
FOR INSERT AS
BEGIN

	DECLARE @newHomeOrg nvarchar(50)	
	SET @newHomeOrg = (SELECT (SELECT SUBSTRING(value, 1, len(value) - 4 ) FROM string_split(Email, '@', 1) WHERE ordinal = 2) FROM inserted)

	IF @newHomeOrg NOT IN (SELECT HomeOrganisationName FROM Home_Organisations)		
		BEGIN
		
		INSERT INTO Home_Organisations(HomeOrganisationName)
		VALUES(@newHomeOrg)

		END
END
GO

-- Checking and reporting completeing all induction courses
CREATE TRIGGER inductionCompleted_00
ON CompletedTrainings
FOR INSERT AS
BEGIN 
	
	DECLARE @PersonProjectID int
	DECLARE @ProjectID int
    DECLARE @PersonID int
	DECLARE @NumCompletedTrainings int
	DECLARE @NumTrainingsProject int
    DECLARE @Title nvarchar(100)
    DECLARE @Email nvarchar(100) 
    DECLARE @ProjectName nvarchar(100)

	SET @PersonProjectID = (SELECT PersonProjectID FROM inserted)

	SET @ProjectID = (SELECT ProjectID FROM PersonProject WHERE PersonProjectID = @PersonProjectID)
    SET @PersonID = (SELECT PersonID FROM PersonProject WHERE PersonProjectID = @PersonProjectID)

	SET @Title = (SELECT Title FROM People_Details WHERE PersonDetailsID = @PersonID)
    SET @Email = (SELECT Email FROM People_Details WHERE PersonDetailsID = @PersonID) 
    SET @ProjectName = (SELECT ProjectName FROM Projects WHERE ProjectID = @ProjectID)     

	SET @NumTrainingsProject = (SELECT COUNT(*) FROM Trainings WHERE ProjectID = @ProjectID AND Mandatory = 1)
	SET @NumCompletedTrainings = (SELECT COUNT(*) FROM CompletedTrainings ct JOIN Trainings t ON ct.TrainingID = t.TrainingID WHERE t.Mandatory = 1 AND ct.PersonProjectID = @PersonProjectID)

	IF @NumCompletedTrainings >= @NumTrainingsProject
		BEGIN

		INSERT INTO InductionCompleted (PersonProjectId, CompletedDate, Title, Email, ProjectName)
		VALUES (@PersonProjectID, CAST(GETDATE() AS DATE), @Title, @Email, @ProjectName)

		END

END
GO