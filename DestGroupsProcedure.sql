SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <piotr.szubert@jacobs.com, InsertDestGroups_00>
-- Create Date: <17.10.2023>
-- Description: <Procedure to insert groups that 
--               user will be added to after induction,
--               to be used in power automate>
-- =============================================

CREATE PROCEDURE [dbo].[InsertDestGroups_00] (
    @FormTrackerID int,
    @GroupIDsList nvarchar(150)
)
AS
BEGIN 

    INSERT INTO [dbo].[DestGroups] (FormTrackID, GroupID)
    SELECT @FormTrackerID, *
    FROM string_split(@GroupIDsList, ';')

END 
GO

