SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[AddInfrastructureUser_00]
ON [dbo].[FormsTracker]
FOR UPDATE AS
BEGIN
SET NOCOUNT ON;
	IF UPDATE (approved)
		BEGIN		

		DECLARE @UserEmail nvarchar(50)
		DECLARE @UserProject nvarchar(50)
		DECLARE @PersonID TABLE (ID int)
		DECLARE @FirstName nvarchar(50)
		DECLARE @LastName nvarchar(50)
		DECLARE @UserHomeOrg nvarchar(50)

		SET @UserEmail = (SELECT Email FROM inserted)
		SET @UserProject = (SELECT Project FROM inserted)
		SET @FirstName = (SELECT FirstName FROM inserted)
		SET @LastName = (SELECT Surname FROM inserted) -- home organisation extracted from email
		SET @UserHomeOrg = ((SELECT SUBSTRING(value, 1, len(value) - 4 ) FROM string_split(@UserEmail, '@', 1) WHERE ordinal = 2))

		PRINT @UserHomeOrg


		-- Check if Home org is on the list
		IF @UserHomeOrg NOT IN (SELECT HomeOrganisationName FROM Home_Organisations)

			BEGIN

			INSERT INTO Home_Organisations (HomeOrganisationName)
			VALUES (@UserHomeOrg)

			END
		

		-- If we do not have new person details we need to add them 
		IF @UserEmail NOT IN (SELECT Email FROM People_Details)
			BEGIN

				BEGIN TRANSACTION

				PRINT @UserHomeOrg
			
					INSERT INTO People_Details (Title, HomeOrganisation, Email) 
					OUTPUT inserted.PersonDetailsID INTO @PersonID -- we need to store auto generated identity into table variable
					VALUES (
						CONCAT(@FirstName, ' ', @LastName), -- TITLE column
						(SELECT HomeOrgID FROM Home_Organisations WHERE HomeOrganisationName = @UserHomeOrg), 
						@UserEmail)
						
				COMMIT TRANSACTION;

			END;	

				
		-- Add new person project connection			
		INSERT INTO PersonProject (PersonID, ProjectID, StartDay, FormID)
		VALUES (
			(SELECT PersonDetailsID FROM People_Details WHERE Email = @UserEmail),
			(SELECT ProjectID FROM Projects WHERE ProjectName = @UserProject),
			CAST(GETDATE() AS DATE),
            (SELECT TrackID FROM inserted))			

		END
END 
GO
ALTER TABLE [dbo].[FormsTracker] ENABLE TRIGGER [AddInfrastructureUser_00]
GO
