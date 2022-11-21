--===================================================================================================--
--==    File Name:    sp_getDatabaseSize.sql                                                       ==--
--==    Author:       Wimpie Norman                                                                ==--
--==    Date:         10/04/2021                                                                   ==--
--==    Description:  Retrieve current DB Size                                                     ==--
--===================================================================================================--

IF EXISTS(SELECT * FROM dbo.sysobjects
          WHERE ID = OBJECT_ID(N'sp_getDatabaseSize')
		  AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)

BEGIN
	PRINT 'DROPPING THE STORED PROCEDURE sp_getDatabaseSize';
	DROP PROCEDURE sp_getDatabaseSize;
END
GO

PRINT 'CREATING THE STORED PROCEDURE sp_getDatabaseSize';
GO

CREATE PROCEDURE sp_getDatabaseSize
(
    @db_name NVARCHAR(100),
	@log_size_mb FLOAT OUTPUT,
	@row_size_mb FLOAT OUTPUT,
	@total_size_mb FLOAT OUTPUT
)

AS

  SELECT 
        @log_size_mb = CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
      , @row_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
      , @total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2))
  FROM sys.master_files WITH(NOWAIT)
  WHERE database_id = DB_ID(@db_name)
      OR @db_name IS NULL
  GROUP BY database_id

RETURN