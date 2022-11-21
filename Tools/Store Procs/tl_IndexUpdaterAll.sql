DECLARE @dbID INT, 
				@txtDynamicSQL NVARCHAR(2000), 
				@txtTableName VARCHAR(255), 
				@txtSchemaName VARCHAR(255), 
				@txtIndexName VARCHAR(255), 
				@intFragPercentage FLOAT, 
				@intPageCount INT;

SET @dbID = DB_ID();

DECLARE CR_IndexFragmentation CURSOR FOR
	SELECT	DISTINCT
					[schema].[name] AS 'schema', 
					[table].[NAME] AS 'tableName',
					[index].[NAME] AS 'indexName',
					[ips].[avg_fragmentation_in_percent] AS 'fragPercentage',
					[ips].[page_count] AS 'pageCount'
	FROM sys.dm_db_index_physical_stats(@dbID, NULL, NULL, NULL, 'DETAILED') ips
	INNER JOIN sys.tables [table] ON [ips].[object_id] = [table].[object_id]
	INNER JOIN sys.indexes [index] ON [ips].[index_id] = [index].[index_id] AND [ips].[object_id] = [index].[object_id]
	INNER JOIN sys.schemas [schema] ON [table].[schema_id] = [schema].[schema_id]
	WHERE PAGE_COUNT > 100 AND AVG_FRAGMENTATION_IN_PERCENT > 3.0
	ORDER BY
		[ips].[avg_fragmentation_in_percent]
OPEN CR_IndexFragmentation;
FETCH NEXT FROM CR_IndexFragmentation INTO @txtSchemaName, @txtTableName, @txtIndexName, @intFragPercentage, @intPageCount;
WHILE (@@fetch_status <> -1)
BEGIN
	SET @txtDynamicSQL = NULL;

	PRINT '' + CAST(GETDATE() AS VARCHAR(250)) + ' - INDEX UPDATER - FOUND: Table:' + @txtTableName + ', Index:' + @txtIndexName + ', Pages:' + CAST(@intPageCount AS VARCHAR(250)) + ', Frag %:' + CAST(@intFragPercentage AS VARCHAR(250)) + '';
	
	IF (@intFragPercentage <= 30.0)
		SET @txtDynamicSQL = 'ALTER INDEX ' + QUOTENAME(@txtIndexName) + ' ON ' + QUOTENAME(@txtSchemaName) + '.' + QUOTENAME(@txtTableName) + ' REORGANIZE';
	ELSE
		SET @txtDynamicSQL = 'ALTER INDEX ' + QUOTENAME(@txtIndexName) + ' ON ' + QUOTENAME(@txtSchemaName) + '.' + QUOTENAME(@txtTableName) + ' REBUILD';
	
	PRINT '' + CAST(GETDATE() AS VARCHAR(250)) + ' - EXECUTING: ' + @txtDynamicSQL;
	EXEC SP_EXECUTESQL @txtDynamicSQL;
	PRINT '' + CAST(GETDATE() AS VARCHAR(250)) + ' - COMPLETED';

	FETCH NEXT FROM CR_IndexFragmentation INTO @txtSchemaName, @txtTableName, @txtIndexName, @intFragPercentage, @intPageCount;
END
CLOSE CR_IndexFragmentation;
DEALLOCATE CR_IndexFragmentation;
GO
