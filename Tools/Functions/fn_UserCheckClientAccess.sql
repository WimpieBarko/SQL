SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [web].[sp_UserCheckClientAccess]
(
	@fkiClientID int,
	@fkiUserID int
)
RETURNS BIT
AS
BEGIN
	DECLARE @blnAccess BIT = 0

	IF ISNULL(@fkiClientID, 0) = 0
		RETURN 1

	-- USER IS AN ADMIN PERSON AND HAS ACCESS ON A CLIENT LEVEL
	IF EXISTS(SELECT * FROM prgClientAccessLevels INNER JOIN tblPeople ON tblPeople.pkiPersonID = prgClientAccessLevels.fkiPersonID
	INNER JOIN prgUserLevels ON prgUserLevels.pkiUserLevelID = tblPeople.intUserLevel
	WHERE prgClientAccessLevels.fkiClientID = @fkiClientID AND tblPeople.pkiPersonID = @fkiUserID AND ISNULL(prgUserLevels.intWebLevel, 0) > 0 AND ISNULL(tblPeople.blnUserLocked, 0) = 0)
		SET @blnAccess = 1
		
	-- USER IS AN ADMIN PERSON AND HAS ACCESS ON A GROUP LEVEL
	IF EXISTS(SELECT * FROM tblAccessGroup INNER JOIN tblAccessGroupType ON tblAccessGroupType.pkiAccessGroupTypeID = tblAccessGroup.fkiAccessGroupTypeID
	INNER JOIN prgPeopleAccessGroups ON prgPeopleAccessGroups.fkiAccessGroupTypeID = tblAccessGroup.fkiAccessGroupTypeID
	INNER JOIN tblPeople ON tblPeople.pkiPersonID = prgPeopleAccessGroups.fkiPersonID
	INNER JOIN prgUserLevels ON prgUserLevels.pkiUserLevelID = tblPeople.intUserLevel
	WHERE tblAccessGroup.fkiClientID = @fkiClientID AND tblPeople.pkiPersonID = @fkiUserID AND ISNULL(prgUserLevels.intWebLevel, 0) > 0 AND ISNULL(tblPeople.blnUserLocked, 0) = 0)
		SET @blnAccess = 1

	-- USER IS A MEMBER AND HAVE ACCESS
	IF EXISTS(SELECT * FROM tblMemberFundInformation INNER JOIN tblPeople ON tblPeople.pkiPersonID = tblMemberFundInformation.fkiPersonID
	WHERE pkiPersonID = @fkiUserID AND ISNULL(tblPeople.intUserLevel, 0) = 0)
		SET @blnAccess = 1

	RETURN @blnAccess
END
GO


