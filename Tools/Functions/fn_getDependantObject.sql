/*************************************************************************
            Use the following code sample to get result:

	SELECT * FROM ebs.fn_getDependantObject ('spf_ContributionPayInvestmentsMember_Bulk')

*************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[ebs].[fn_getDependantObject]') AND [type] IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [ebs].[fn_getDependantObject]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION ebs.fn_getDependantObject (@object_name VARCHAR(255))  
RETURNS TABLE  
AS  
RETURN   
(  
	SELECT referencing_schema_name, referencing_entity_name, referencing_id, referencing_class_desc, is_caller_dependent
	FROM sys.dm_sql_referencing_entities (@object_name, 'OBJECT')
);  
		