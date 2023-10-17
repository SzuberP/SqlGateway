/****** CREATE PEOPLE - PORTAL GROUPS RELATIVE TABLE  ******/
CREATE TABLE PersonGroup (
PersonGroupID int PRIMARY KEY IDENTITY(1000,1) NOT NULL,
PersonProjectID int NOT NULL,
GroupID int NOT NULL,
CONSTRAINT FK_Person FOREIGN KEY (PersonProjectID)
REFERENCES PersonProject(PersonProjectID),
CONSTRAINT FK_Group FOREIGN KEY (GroupID)
REFERENCES Portal_Groups(PortalGroupID)
)

  
CREATE VIEW PeopleInGroups
AS
	SELECT pd.Title, pd.Email, p.ProjectName, pg.GroupID, p_g.PortalGroupName, pd.HomeOrganisation 
	FROM PersonGroup pg
	JOIN PersonProject pp
	ON pg.PersonProjectID = pp.PersonProjectID
	JOIN People_Details pd
	ON pp.PersonID = pd.PersonDetailsID
	JOIN Projects p
	ON pp.ProjectID = p.ProjectID
	JOIN Portal_Groups p_g
	ON pg.GroupID = p_g.PortalGroupID

CREATE VIEW PeopleView
AS 
	SELECT pd.Title, pd.Email, ho.HomeOrganisationName, p.ProjectName, pp.PersonProjectID, pd.PersonDetailsID, p.ProjectID
	FROM PersonProject pp
	JOIN People_Details pd
	ON pp.PersonID = pd.PersonDetailsID
	JOIN Projects p
	ON pp.ProjectID = p.ProjectID
	JOIN Home_Organisations ho
	ON pd.HomeOrganisation = ho.HomeOrgID


SELECT *
FROM PersonGroup

INSERT INTO PersonGroup (PersonProjectID, GroupID)
VALUES (1082, 10)

