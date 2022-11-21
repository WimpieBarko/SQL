--====================================================================================================--
--==  File Name: spf_findValueLocation                                                              ==--
--==  File Type: Store Procedure                                                                    ==--
--==  Desc     : This store procedure will print out SP with required changes                       ==--
--==  Example  : EXEC ebs.spf_findValueLocation 'EBS','tmpHelptext', 'txtText', 'pkiHelpTextID',    ==--
--==			 'SET NOCOUNT', 1391, 1384, 'pkiHelpTextID', 'ASC', @intReturn OUTPUT               ==--                                                                                 
--====================================================================================================--

IF OBJECT_ID('ebs.spf_findValueLocation', 'P') IS NOT NULL
BEGIN
	PRINT '[DROP]:[Droppig the following store procedure {ebs.spf_findValueLocation}]'
	DROP PROCEDURE [ebs].[spf_findValueLocation]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [EBS].[spf_findValueLocation] 
(
	@txtPropertySchema VARCHAR(10), 
	@txtProperty VARCHAR(255), 
	@txtPropertyType VARCHAR(255), 
	@txtPropertyPrimary VARCHAR(255), 
	@txtPropertyValue VARCHAR(255), 
	@intBefore INT, 
	@intAfter INT, 
	@txtOrderType VARCHAR(255), 
	@txtOrderBy VARCHAR(4), 
	@intReturn INT OUTPUT
)
AS 
SET NOCOUNT ON
BEGIN
	DECLARE @intError INT,
			@txtDynamicSQL NVARCHAR(MAX)

	SET @intError = 0

	IF @txtProperty = '' OR @txtProperty IS NULL
	BEGIN 
		RAISERROR('[Error]:[Please ensure that the following variable is not null {@txtProperty}]',16,1)
		SET @intError = 1
	END

	IF @txtPropertyValue = '' OR @txtPropertyValue IS NULL
	BEGIN 
		RAISERROR('[Error]:[Please ensure that the following variable is not null {@txtPropertyValue}]',16,1)
		SET @intError = 1
	END

	IF @txtOrderBy IS NOT NULL OR @txtOrderBy <> ''
	BEGIN
		IF @txtOrderType IS NULL OR @txtOrderType = ''
		BEGIN
			RAISERROR('[Error]:[Please ensure that you supply a @txtOrderType value with {@txtOrderBy}]',16,1);
			SET @intError = 1
		END
	END

	IF @txtOrderType IS NOT NULL OR @txtOrderType <> ''
	BEGIN
		IF @txtOrderBy IS NULL OR @txtOrderBy = ''
		BEGIN
			RAISERROR('[Error]:[Please ensure that you supply an {ASC} or {DESC} value with {@txtOrderType}]',16,1)
			SET @intError = 1
		END
	END

	IF @intError = 0
	BEGIN
		CREATE TABLE #tmpFindValueLoc
		(
			[pkiFindValueLoc] INT IDENTITY(1,1),
			[txtProperty] VARCHAR(255),
			[intPropertyLoc] INT
		)
		
		IF (@intBefore = 0) AND (@intAfter = 0)
		BEGIN
			SET @txtDynamicSQL =
			'
				DECLARE @intReturn INT

				SET @intReturn = (SELECT TOP 1 ' +QUOTENAME(@txtPropertyPrimary) + ' FROM ' + QUOTENAME(@txtPropertySchema) + '.' + QUOTENAME(@txtProperty) + ' WHERE ' + QUOTENAME(@txtPropertyType) + ' LIKE ''%' + @txtPropertyValue + '%'' ORDER BY ' + QUOTENAME(@txtOrderType) + ' ' + @txtOrderBy + ')

				IF @intReturn IS NOT NULL
				BEGIN
					INSERT INTO #tmpFindValueLoc (txtProperty,intPropertyLoc) VALUES (''' + QUOTENAME(@txtPropertyValue) + ''',@intReturn)
				END
			'
		END
		
		IF (@intBefore <> 0) AND (@intAfter = 0)
		BEGIN
			SET @txtDynamicSQL =
			'
				DECLARE @intReturn INT

				SET @intReturn = (SELECT TOP 1 ' +QUOTENAME(@txtPropertyPrimary) + ' FROM ' + QUOTENAME(@txtPropertySchema) + '.' + QUOTENAME(@txtProperty) + ' WHERE (' + QUOTENAME(@txtPropertyType) + ' LIKE ''%' + @txtPropertyValue + '%'') AND (' + QUOTENAME(@txtPropertyPrimary) + ' < ' + CONVERT(VARCHAR(10),@intBefore) + ') ORDER BY ' + QUOTENAME(@txtOrderType) + ' ' + @txtOrderBy + ')

				IF @intReturn IS NOT NULL
				BEGIN
					INSERT INTO #tmpFindValueLoc (txtProperty,intPropertyLoc) VALUES (''' + QUOTENAME(@txtPropertyValue) + ''',@intReturn)
				END
			'
		END

		IF (@intBefore = 0) AND (@intAfter <> 0)
		BEGIN
			SET @txtDynamicSQL =
			'
				DECLARE @intReturn INT

				SET @intReturn = (SELECT TOP 1 ' +QUOTENAME(@txtPropertyPrimary) + ' FROM ' + QUOTENAME(@txtPropertySchema) + '.' + QUOTENAME(@txtProperty) + ' WHERE (' + QUOTENAME(@txtPropertyType) + ' LIKE ''%' + @txtPropertyValue + '%'') AND (' + QUOTENAME(@txtPropertyPrimary) + ' > ' + CONVERT(VARCHAR(10),@intAfter) + ') ORDER BY ' + QUOTENAME(@txtOrderType) + ' ' + @txtOrderBy + ')

				IF @intReturn IS NOT NULL
				BEGIN
					INSERT INTO #tmpFindValueLoc (txtProperty,intPropertyLoc) VALUES (''' + QUOTENAME(@txtPropertyValue) + ''',@intReturn)
				END
			'
		END

		IF (@intBefore <> 0) AND (@intAfter <> 0)
		BEGIN
			SET @txtDynamicSQL =
			'
				DECLARE @intReturn INT

				SET @intReturn = (SELECT TOP 1 ' +QUOTENAME(@txtPropertyPrimary) + ' FROM ' + QUOTENAME(@txtPropertySchema) + '.' + QUOTENAME(@txtProperty) + ' WHERE (' + QUOTENAME(@txtPropertyType) + ' LIKE ''%' + @txtPropertyValue + '%'') AND (' + QUOTENAME(@txtPropertyPrimary) + ' > ' + CONVERT(VARCHAR(10),@intAfter) + ') AND (' + QUOTENAME(@txtPropertyPrimary) + ' < ' + CONVERT(VARCHAR(10),@intBefore) + ') ORDER BY ' + QUOTENAME(@txtOrderType) + ' ' + @txtOrderBy + ')

				IF @intReturn IS NOT NULL
				BEGIN
					INSERT INTO #tmpFindValueLoc (txtProperty,intPropertyLoc) VALUES (''' + QUOTENAME(@txtPropertyValue) + ''',@intReturn)
				END
			'
		END

		EXEC(@txtDynamicSQL)

		SET @intReturn = (SELECT TOP 1 intPropertyLoc FROM #tmpFindValueLoc WHERE txtProperty LIKE  '%' + @txtPropertyValue + '%')

		IF @intReturn IS NULL
		BEGIN
			SET @intReturn= 0
		END
	END
END
GO