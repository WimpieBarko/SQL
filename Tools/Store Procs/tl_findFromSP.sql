--===================================================================================================--
--==    File Name:    tl_findFromSP.sql                                                           ==--
--==    Author:       Wimpie Norman                                                                ==--
--==    Date:         02/11/2022                                                                   ==--
--==    Description:  Retrieve SP Names from where the content exist.                              ==--
--===================================================================================================--
/******************************		Example		******************************/

/*					EXEC dbo.tl_findFromSP '#test'			                         */

/******************************		Example		******************************/

IF EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.tl_findFromSP') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
BEGIN
	PRINT 'DROPPING THE STORED PROCEDURE dbo.tl_findFromSP';
	DROP PROCEDURE dbo.tl_findFromSP;
END
GO

PRINT 'CREATING THE STORED PROCEDURE dbo.tl_findFromSP';
GO
--EXEC tl_findFromSP NULL, 'F_BFS_XML_C17'
CREATE PROCEDURE dbo.tl_findFromSP
(
	@txtSP NVARCHAR(MAX),
  @txtValue NVARCHAR(MAX)
)

AS
	-- Trim the input value
	SET @txtValue = LTRIM(RTRIM(@txtValue))

	DECLARE @dynamic_SQL NVARCHAR(MAX);

	SET @txtSP = ISNULL(@txtSP,'')
	
	-- Create Dynamic SQL that will create a table variable to store the result set and display the content as XML.
	SET @dynamic_SQL =
	'
		DECLARE @tblResult TABLE
		(
			[pkTableID] BIGINT IDENTITY(1,1) PRIMARY KEY,
			[txtResultProperty] NVARCHAR(MAX),
			[txtResult] NVARCHAR(MAX)
		)

		INSERT INTO @tblResult
		(
			[txtResultProperty],
			[txtResult]
		)
		SELECT DISTINCT 
			   [routines].ROUTINE_NAME AS ''txtResultProperty'',
			   [routines].[ROUTINE_DEFINITION] AS ''txtResult''
		FROM INFORMATION_SCHEMA.ROUTINES [Routines]
		WHERE ROUTINE_DEFINITION LIKE ''%' + @txtValue + '%''
		AND ROUTINE_TYPE = ''Procedure''

		SELECT txtResultProperty AS ''SP Name'',
			   CONVERT(XML,(SELECT [txtResult] AS ''txtResult'' FROM @tblResult B WHERE B.txtResultProperty = A.txtResultProperty   FOR XML PATH(''''))) AS ''SP Content''			   
		FROM @tblResult A
	'
	EXEC(@dynamic_SQL)


