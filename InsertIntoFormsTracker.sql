SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <piotr.szubert@jacobs.com, InsertDestGroups_00>
-- Create Date: <Last update: 17.10.2023>
-- Description: <Procedure loading data from MS Forms,
--               to be used in powerautomate>
-- =============================================
ALTER PROCEDURE [dbo].[InsertIntoFormsTracker_00]
(
    @FormsID nvarchar(100),
	@FirstName nvarchar(50),
	@Surname nvarchar(50),
	@Email nvarchar(100),
	@PW_Level nvarchar(20),
	@Approved bit, 
	@Project nvarchar(50),
    @GroupsIdsList nvarchar(150)
)
AS
BEGIN

    INSERT INTO [dbo].[FormsTracker] (FormsID, FirstName, Surname, Email, PW_Level, Approved, Project)
	VALUES (@FormsID, @FirstName, @Surname, @Email, @PW_Level, @Approved, @Project);

    DECLARE @FormTrackerID int
	SET @FormTrackerID = SCOPE_IDENTITY()

    EXECUTE InsertDestGroups_00 
        @FormTrackerID,
        @GroupsIdsList; 

	-- returning 
	SELECT  SCOPE_IDENTITY() AS [SCOPE_IDENTITY]     
    

END
GO
