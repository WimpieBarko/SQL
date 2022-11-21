--===================================================================================================--
--==    File Name:    utils_RootBlocker.sql		                                                   ==--
--==    Author:       Wimpie Norman                                                                ==--
--==    Date:         28/04/2021                                                                   ==--
--==    Description:  Looking For The Root Blocker & blocked sessions.                             ==--
--===================================================================================================--
--<< List down all the blocking process or root blockers >>--
SELECT  DISTINCT 
		p1.spid  AS 'Blocking/Root Blocker SPID'
	   ,p1.loginame AS 'Root Blocker Login'
	   ,st.text AS 'SQL Query Text'  
	   ,p1.CPU  AS 'CPU'
	   ,p1.Physical_IO AS 'Physical IO'
	   ,DB_NAME(p1.[dbid]) AS 'Database Name'
	   ,p1.Program_name AS 'Program Name'
	   ,p1.HostName AS 'Host Name'
	   ,p1.Status AS 'Status'
	   ,p1.CMD  AS 'CMD'
	   ,p1.Blocked AS 'Blocked'
	   ,p1.ECID AS 'ExecutionContextID'

FROM  sys.sysprocesses p1
	INNER JOIN  sys.sysprocesses p2 ON p1.spid = p2.blocked AND p1.ecid = p2.ecid
	CROSS APPLY sys.dm_exec_sql_text(p1.sql_handle) st
WHERE p1.blocked = 0
ORDER BY p1.spid, p1.ecid



--<< List Down all the blocked processes >>--
SELECT  p2.spid AS 'Blocked SPID'
	   ,p2.blocked AS 'Blocking/Root Blocker SPID'
	   ,p2.loginame AS 'Blocked SPID Login'
	   ,st.text AS 'SQL Query Text'
	   ,p2.CPU AS 'CPU'
	   ,p2.Physical_IO AS 'Physical IO'
	   ,DB_NAME(p2.[dbid]) AS 'Database Name'
	   ,p2.Program_name AS 'Program Name'
	   ,p2.HostName AS 'Host Name'
	   ,p2.Status AS 'Status'
	   ,p2.CMD  AS 'CMD'
	   ,p2.Blocked AS 'Blocked'
	   ,p2.ECID AS 'ExecutionContextID'
FROM sys.sysprocesses p1
	INNER JOIN sys.sysprocesses p2 ON p1.spid = p2.blocked AND p1.ecid = p2.ecid
	CROSS APPLY sys.dm_exec_sql_text(p1.sql_handle) st