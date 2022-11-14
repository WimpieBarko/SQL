# **SQL Coding Standards**
## **<ins>Contents</ins>**

- [Overview](#overview)
- [Purpose](#purpose)
- [Standard Categories](#standard-categories)
- [Object Naming Standards](#object-naming-standards)
- [Approved Object Name Abbreviations](#approved-object-name-abbreviations)
- [Table Names](#table-names)
- [Column and Variable Names](#column-and-variable-names)
- [Index Names](#index-names)
- [Naming Views, Check Constraints, Defaults, and Rules](#naming-views-check-constraints-defaults-and-rules)
- [Stored Procedure Names](#stored-procedure-names)
- [DTS Package and SQL Job Names](#dts-package-and-sql-job-names)
- [DML Syntax Standard](#dml-syntax-standard)
- [General Stored Procedure Standard](#general-stored-procedure-standard)
- [Error Handling Standard](#error-handling-standard)

---
## **<ins>Overview</ins>**


<p>This document sets forth guidelines for the SQL Coding Standards for Barko Financial Services</p>

---
## **<ins>Purpose</ins>**


<p>SQL coding standards are maintained by database administrators, Management, Team-Lead in the
development database group. The target audience is DBA’s, SQL
Developers, and anyone who writes SQL code that will be deployed to a
production environment.

Deployable SQL code can be stored procedures, DTS packages, SQL jobs,
replication filters, or SQL embedded in client objects. Standards are
grouped into four categories: object naming, DML (data manipulation
language) syntax, error handling, and general stored procedure
guidelines. Strictly speaking, object naming standards could be
documented separately, since they apply to database objects as well as
SQL code. They are contained in this SQL Coding Standards document for
purposes of convenience at this time. Note that formatting of SQL
embedded in client objects may be governed by SQL Standards for the
client object.

It is expected that all new SQL code will adhere to these standards;
existing code can be retrofitted to meet the standards to whatever
degree possible, as modifications to that code are required. Note that
implementation of error handling in only a subset of stored procedures
will reduce the utility of a standardized approach.</p>

---
## **<ins>Standard Categories</ins>**

<p>Object Naming Standards define how tables, columns, stored procedures,
etc are named. A list of approved abbreviations or short names (for
example, Appl for Application; Num for Number rather than Nbr) is
included here. This list is maintained by the database development group
as part of the object naming standard.

DML syntax standard defines guidelines for writing selects, inserts,
updates, and deletes.

General Stored Procedure Standards are a guideline for formatting,
parameter/variable names, and in-line documentation.

Error Handling Standard defines how the various types of errors that may
occur during execution of SQL code are trapped and handled.
Recommendations for implementing transactions are also contained in this
section. Note that client handling of errors returned from the database
is not addressed in this standards document, but is an important factor
in the overall efficacy of a standard error handling approach.</p>

---
## **<ins>Object Naming Standards</ins>**

Object names will be English words and abbreviations, which convey
meaning about what the object represents in the system. Mixed-case will
be used for readability, without underscores or other special
characters. Where a prefix is appropriate for an object, the prefix will
follow mixed-case formatting. Abbreviations for common words should be
used across the board; a list of standard abbreviations is provided
later in this document.

General naming guidelines:

-   Avoid using `numbers`; if a number is absolutely required, spell it
    out as a word.
-   Avoid using `proprietary acronyms` (GDSINC, SQL)
-   Avoid using `product-specific names`, or names whose meaning is
    subject to change (Schema, DCN159)
-   Use the `singular form` (i.e. the Loan table and not the Loans table).
-   `Camel capitalization` (i.e. mixed-case) should be used on all
    identifiers (for example, FirstName, LogDetail, AcctSysId,
    LkupCountryCode, @ErrNum, etc).
-   Never name an object with a SQL Server reserved word. See Books
    Online, ‘Reserved Keywords’ section.

---
## **<ins>Approved Object Name Abbreviations</ins>**

Some objects should be named in an abbreviated form, when they are part
of database object names. Please see DBA staff to suggest other
abbreviated forms for inclusion.

| Business Name  | Abbreviation | 
|----------------|--------------| 
| Account        | Acct         | 
| Address        | Addr         | 
| Administration | Admin        | 
| Amount         | Amt          | 
| Application    | Appl         | 
| Attribute      | Attr         | 
| Business       | Bus          | 
| Date           | DT           | 
| Description    | Desc         | 
| Document       | Doc          | 
| Identifier     | ID           | 
| Number         | Num          | 
| Parameter      | Parm         | 
| Passport       | PPT          | 
| Percent        | Pct          | 
| Sequence       | Seq          | 
| System         | Sys          | 

**[Contents](https://github.com/WimpieBarko/SQL/edit/main/README.md#contents)** 

---
## **<ins>Table Names</ins>**

Data tables are defined as tables containing data specific to the
business of the application. Their names may include a prefix, to group
tables of similar business purpose. The set of approved data table name
prefixes is defined below (TBD):

| Prefix | Definition               | 
|--------|--------------------------| 
| Lkup   | Lookup data              | 
| Imp    | “Import” or staging data | 


Non-data tables are used for more generic purpose: error handling,
maintenance, work holding space, etc. Their names may also include a
prefix and a suffix as well. The suffix is used to indicate a more
general grouping by purpose. General definitions of non-data tables,
whose naming convention may include a prefix, suffix, or both, are given
below:

\[All prefixes should be in camel case. All suffixes should be upper
case, with no underscore\]

| Table Group                                       | Definitions                                                             | Prefix                                   | Suffix                      | 
|---------------------------------------------------|-------------------------------------------------------------------------|------------------------------------------|-----------------------------| 
| Application Static Tables (code lookup tables)    | State code and other code lookup tables.  os = Operational Standards    | os (Note: going forward, we will use the Lkup prefix.) | (no suffix)               |                                          |                             | 
| System Utility Tables                             | Tables to support Administrative utilities                              | admin                                    | (no suffix)                 | 
| Persistent Work Tables                            | Tables to support interim work steps                                    | Application Group Name  where Appropriate                                 | WORK                                                                    |                                          |                             | 
| Staging Tables (For import/export)                | Tables used to hold imported and exported data                          | Application Group Name where Appropriate | (no suffix; use Inp prefix) | 
| Backup Tables                                     | Tables used to back up other tables                                     | Application Group Name where Appropriate | BKUP                        | 

**[Contents](https://github.com/WimpieBarko/SQL/edit/main/README.md#contents)** 

---
## **<ins>Column and Variable Names</ins>**

Columns name should provide a clear, concise description of the
attribute in mixed case, without prefixes or underscores.

Any system-generated identifiers will always have the suffix ‘ID’. The
full column name will be the table name plus the suffix. All fields that
reference a lookup table should include a suffix of ‘Code’ when
referencing an actual code values versus ‘ID’ when referencing a
surrogate integer field.

Columns that are foreign keys to another table, should preserve the
column name across the relationship. An exception to this rule must be
made when there are two foreign key columns representing the same
primary key.

Do not use ‘timestamp’ or ‘TS’ as part of the column name of a datetime
column,since timestamp is a non-temporal datatype; the name is misleading.

UID \[Unique Identifier\] is a binary record identifier that is unique
across all agencies. By Type the definitions are:

| Database Data Type  | Format                          | Example               | 
|---------------------|---------------------------------|-----------------------| 
| Primary Key         | pki +  column name + ID         | pkiCountryID          | 
| Foreign Key         | fki +  column name + ID         | fkiRegionID           | 
| Text                | txt +  column name              | txtDescription        | 
| Integer             | int +  column name              | intCounter            | 
| Date                | dte +  column name              | dteCreatedDate        | 
| Boolean/Decision    | bln +  column name              | blnVerified           | 

**[Contents](https://github.com/WimpieBarko/SQL/edit/main/README.md#contents)** 

---
## **<ins>Index Names</ins>**

Index names should provide a clear and concise description of the index.
An upper-case prefix is always used in the index name to indicate the
type of index, and should include an underscore separator. The body of
the index name includes the table name and may include the name(s) of
the columns indexed. By type, the definitions are as follows:

| Index Type        | Naming convention                                                                 | Example          | 
|-------------------|-----------------------------------------------------------------------------------|------------------| 
| Primary Key       | PK_  +  Name of Table                                                             | PK_pTDISAppl     | 
| Foreign Key       | FK_ +  Name of Table + ‘_’ + Name of Column  (first column name required, rest optional) | FK_Trace_BatchID |                  | 
| Alternative Key   | AK_ + name of Table + ‘_’ + Name of Column       This type of index is associated with a unique constraint on a table (i.e., an alternate primary key). | AK_Acct_SSN  |                  | 
| Other             | An index that is not related to a primary, foreign, or ‘alternative’ key on the table. | IX_Acct_LastName | 

**(open issue, should be clearly identify clustered keys)**

**[Contents](https://github.com/CA-CST-SII/Software-Standards/blob/master/SQL%20Server%20Coding%20Standards.md#contents)** 

---
## **<ins>Naming Views, Check Constraints, Defaults, and Rules</ins>**

Check constraints are preferred over rules; do not create new rules,
which are supported as a back-ward compatibility feature of SQL Server
2000. The naming conventions for views, check constraints, and defaults
consist of a prefix, underscore, and descriptive name.

The descriptive name of these objects should include the purpose of the
code behind the object; the table or column name may be included. A view
name should include the purpose and a reference to the main type of data
in the view, for example, vwRejectedPassport. Check constraint names
must be unique, so a reference to the object table name is appropriate;
however, the table name can be embedded in the descriptive name (for
example, CHK\_ApplicationNameIsValid).

| Database Object  | Format                          | Example               | 
|------------------|---------------------------------|-----------------------| 
| Default          | df_ +  table name + column name | df_ApplicationSSN     | 
| View             | v_ + name                       | v_AcctPersonProfile   | 
| Check Constraint | CHK_ + name                     | CHK_ApplicationFeeMax | 

**[Contents](https://github.com/CA-CST-SII/Software-Standards/blob/master/SQL%20Server%20Coding%20Standards.md#contents)** 

---
## **<ins>Stored Procedure Names</ins>**

Procedures may be grouped by purpose or by the name of the entity
processed. For example, there may be a group of procedures that
manipulate Application data. Those procedures might be named
ApplicationInsert, ApplicationUpdate, ApplicationDelete, etc. In
general, naming procedures with a ‘noun + verb’ format, works well for
grouping by purpose.

If entity names are not appropriate as a grouping prefix, the
table-grouping prefixes in section 3.1.2 of this document can be used.

Do not use sp\_ as the prefix of a stored procedure name; the query
engine looks for these first in the master database, so a performance
dip can result.

**[Contents](https://github.com/WimpieBarko/SQL/edit/main/README.md#contents)** 

---
## **<ins>DTS Package and SQL Job Names</ins>**

DTS Package and SQL Job names should be prefixed with the primary
project it supports (for example: TDISArchiveETL,
MISPassportSpecialistETL, TDISAgencyPurge, etc).

**[Contents](https://github.com/WimpieBarko/SQL/edit/main/README.md#contents)** 

---
## **<ins>DML Syntax Standard</ins>**

Include the table owner when referencing a table in DML (i.e., select
columnA from dbo.tableB). Otherwise, SQL server looks to see if the user
running the query owns the table, rather than dbo. Performance is
improved by always including the table owner in the reference.

Do not use ‘select \* ’ since columns can be added, changed, or removed
from a table. Instead, reference each column that is returned from the
select, by name.

In general, do not use ‘select into’ to create a new table variable or
temporary table, within a stored procedure. It is better practice to
define the table variable or temporary table, at the top of the
procedure.

Use ANSI-92 standard SQL syntax. This includes DELETE FROM and INNER /
OUTER / LEFT join syntax. A good concise source for checking ANSI SQL
syntax is <http://www.ocelot.ca/commands.htm>.

---
### **<ins>General Stored Procedure Standard</ins>**

Following is a template to use when creating a stored procedure. Some
general standard guidelines that are demonstrated within the template
are:

1. Input parameter names are prefixed with the same standard as defined in section ``
2. It is recommended that variable names be declared immediately after
the comments section. Variable names should be descriptive.
3. Define the parameters immediately after the declaration. Within the
parameter definition, it is recommended to default parameters to NULL,
then check for required parameters so that missing values can be handled
gracefully.
4. The header info for the SP goes after the ‘create procedure’
statement, so that the comments are included in the SP when it is
installed in the database.
5. Define all parameters to a stored procedure as NULL (or otherwise
default them to a value). Then, as one of the first steps in the SP,
check whether REQUIRED inputs were input as null. If they were, raise an
error. This is a graceful way of handling SP calls that did not supply
required values.
6. Execute sub-procedure calls in a standard fashion: check both the
return code and @@error after the call; qualify the procedure name with
the owner name.
7. Execute sub-procedure calls by explicitly setting the input values
equal to the parameter names, rather than depending upon the position.
8. GOTO’s are only permitted in the error handling portion of the code.
9. All SPs should be indented (recommended 2 spaces per indent) per the
following example.

```SQL
IF EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'Schema_Name.SP_Name') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
BEGIN
	PRINT '[DROP]:[Dropping the stored procedure Schema_Name.SP_Name]';
	DROP PROCEDURE dbo.sp_ProcessQueue;
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT '[CREATE]:[Creating the stored procedure Schema_Name.SP_Name]';
GO

CREATE PROCEDURE [Schema_Name].[SP_Name] 
(
  @txtParmOne VARCHAR(255) = NULL,      -- define the parm, such as 'Last name of the applicant'
  @intParmID INT = NULL,                -- define the parm, such as 'Identifier to the application being processed'
  @outReturn INT = NULL OUTPUT          -- define the parm, such as 'Identifier to the login created by this SP'
) 
AS
SET NOCOUNT ON
/* [DESCRIPTION]
 * (detailed description, such as:
 *
 *  This SP is used to create new ApplicationDetail information on a passport applicant.
 *  It is called from the DOSPassport application, and passes back an identifier to
 *  the applicant's new login.
 *
 * [CHANGE INFORMATION]
 * Author            Date            Description of Change
 * ------            ----            ---------------------
 * <Author>          3/25/2022       Created
 *
 * [RETURNS]
 * (Single record, Recordset, integer, ...)
 */
 
DECLARE @intErrNum INT,
        @intReturnCode INT,
        @txtSysName VARCHAR(35),
        @txtErrMsg VARCHAR(255),
        @intRowCount INT 
        
/** Init some variables **/
set @intErrNum = 0
set @txtSPName = object_name(@@procid)

/** check the required parameters **/
IF ISNULL(@intParmID, 0) < 1 Or ISNULL(@txtParmOne, '') = ''
BEGIN
  SET @txtErrMsg = 'A required input parameter (ParmID or ParmOne) is missing.'
  GOTO ERR_HANDLER
END

/**  when calling other stored procedures, check both ReturnCode and @@error.  Always have a stored procedure return **/
/**  ZERO if there were no errors during execution.  Do NOT use the return code to return parameter values - use **/
/**  OUTPUT variables for that. **/

EXEC @intReturnCode = dbo.spSomeOtherProcedure @txtInputParmName = @txtParmOne

SET @intErrNum = @@ERROR
IF @intReturnCode <> 0 or @intErrNum <> 0
BEGIN
  IF @intErrNum = 0 
	BEGIN
    SET @intErrNum = @intReturnCode  -- this preserves all errors
    SET @txtErrMsg = 'Make this a descriptive msg: Error returned from spSomeOtherProcedure; error: '
                     + CONVERT(VARCHAR(11), @intErrNum) + '.'
    GOTO ERR_HANDLER
	END
END
 
/** Here we show how to perform an insert and do some checking. **/
BEGIN TRANSACTION
	INSERT dbo.SomeTable (ColA, ColB, ColC)
	SELECT b.Colxx, b.Colyy, b.Colzz
	FROM dbo.Table1 a inner join dbo.Table2 b ON a.PKcol = b.FKCol
	WHERE b.ParmID = @intParmID

	SELECT @intRowCount = @@intRowCount, @intErrNum = @@ERROR

	IF @intErrNum <> 0 or @intRowCount <> 1
	BEGIN
		ROLLBACK TRANSACTION
		SET @txtErrMsg = 'Error inserting SomeTable using ParmID ' + CONVERT(VARCHAR(10), @intParmID)
					+ '; error, rowcount ' + CONVERT(VARCHAR(11), @intErrNum) + ', '
					+ CONVERT(VARCHAR(11), @intRowCount) + '.'
		GOTO ERR_HANDLER
	END

/** if we are here we can commit the transaction **/
COMMIT TRANSACTION

END_PROC:
  RETURN @intErrNum
		/**  this error handler captures the error in errLog, then raises an error and returns a non-zero error number. **/
ERR_HANDLER:
  INSERT dbo.ErrLog (ErrNum, ErrSource, ErrDesc, CreatedFromHost)
  SELECT @intErrNum, @txtSPName, @txtErrMsg, HOST_NAME() 
  
	RAISERROR(@txtErrMsg, 16, 1)
  SELECT @intErrNum = @@ERROR  
  GOTO END_PROC
```
Other stored procedure standards not demonstrated in the template
include:

10. When using dynamic SQL, use sp\_executesql, as the error information returned from that system proc is more robust than simply using ‘exec’. In addition, use parameterized queries with sp\_executesql whenever possible; this promotes query plan reuse. 
11. If a stored procedure begins a transaction and calls another stored proc that contains transactions, consider implementing the inner transaction via savepoints (SAVE TRANSACTION). This allows greater flexibility in rolling back the inner transaction, without disturbing the outer transaction. SQL Server does not support true nested transactions, but savepoints plus rigorous error checking can mimic nested transaction functionality pretty well. The one wrinkle is that error logging done in the ‘inner’ stored procedure, will be lost when the outer transaction rolls back, if it needs to. SQL Server 2005 supposedly will introduce the concept of error queues, so that even when an outer transaction is rolled back, the inner
error can be captured. 
12. Consistently return ZERO from a stored procedure if no errors are detected; return a non-zero value if an error
is detected. 
13. Liberally comment stored procedures in-line. In particular, when code or logic is complex or its purpose not easily
discernible, even a brief comment can help with future maintenance. Avoid code ‘shortcuts’ that may decrease the lines of code in a procedure, but make it harder to understand (for example, re-using local variables for different purposes at different points in the code). 
14. A local variable naming standard is not mandated at this time. However, consistency of naming methodology within a procedure is desirable. Variable names should match table column names for consistency. If underscores are preferred instead of mixed case in local variable names, use that method consistently within the procedure. 
15. When a modification is made to a stored procedure that has been deployed to production, a comment in the header of the procedure is required as well as describing what the mod was (i.e., ‘Added new parameter @pNewApp.’).
The reason for the mod and the CR\# are also required (‘Added new parameter @pNewApp in order to filter result set by application; required for new OPS report; see CR \#505.’).

**[Contents](https://github.com/CA-CST-SII/Software-Standards/blob/master/SQL%20Server%20Coding%20Standards.md#contents)** 

---
### **<ins>Error Handling Standard</ins>**

In SQL Server 2000, error handling is notoriously inconsistent. The upcoming version is reputed to have only minor improvements in how errors are returned.

A review of what can happen when an error occurs in T-SQL (from the least drastic to the most drastic):

1. The current statement is aborted and rolled back, but execution continues on to the next statement. No transaction is rolled back. Typicalerrors of this kind are PK/FK constraint violations. Note: if SET XACT\_ABORT is set ON, this type of error aborts the batch (like type 1 below) and is therefore impossible to trap. Do not set XACT\_ABORT to ON.
2. The running scope is terminated. The typical error of this type is a reference to a non-existent object or table column, or some other query-parsing error that happens at runtime. Execution continues in the caller of the scope, and any open transaction remains active. ‘Scope’ is normally a stored procedure. The return value from the SP in which the
error happens, will be null in this case; @@error, however, will most likely be set.
3. The process is terminated, and everything is rolled back. These are known as fatal errors or batch-aborting errors. Examples are access violations and data conversion errors. These errors can only be trapped by the client, not by T-SQL code. An explicit rollback command in a trigger (or an ‘implicit’ rollback that results if ANY error gets raised by SQL Server during the trigger’s execution) also falls into this category, so error handling in triggers is very tricky. Open
transactions are always rolled back in this type of error. 

In order to trap errors of the first 2 types and to avoid type 3 whenever possible, the guidelines are:

1. Return ZERO from a stored procedure if it executes without error; otherwise, return a non-zero value. 
2. After each stored procedure call, check both the return value and @@error. If either is not zero, handle that as an error. 3. Capture the explicit SQL Server error number at the lowest level possible, so that the code where the error occurred can be flagged. 
4. Store error information in a permanent SQL Server table. Information that should be captured includes SPName, ErrNum, ErrMsg, HostName, and CreateDate. In addition, have CLIENT code also write error information to a SQL Server table (using the same table as stored procedures write to is fine). This is needed because type 3 errors (see above) cannot be trapped by SQL Server. 
5. Trigger code should never issue an explicit rollback, as this aborts the SQL Server batch and is only trappable by the client. Instead, when trigger code discerns an error, it should issue a raiserror with an appropriate message, and let the code that issued the insert, update, or delete, check @@error after the statement. Then, the code can rollback as appropriate. However, this strategy works mostly for business-rule type errors that can be caught in the trigger code. A FK violation that occurs inside of a trigger, for example, aborts the batch and no handling is possible. Note that replication that kicks off triggers on the subscriber, needs to be handled a little differently. There, explicit rollbacks are more
appropriate than issuing raiserror commands, since there is no batch process to check @@error that is part of replication. In this case, explicit rollbacks in a subscriber trigger will cause a replication failure, which is what needs to happen so the problem can be brought to administrative attention and fixed. 
6. Do not use SET XACT\_ABORT ON, as this escalates a type \#1 error to a type \#3. The exception to this rule is if a design decision is made to handle all database errors in the client code.

*The stored procedure template in section 3.3 of this document contains sample error handling code that demonstrates many of the above guidelines*

*If you do not use any of the error handling guidelines as specified in this document, you must include a detailed description of why you chose to not do so in the header section of the stored procedure.*

**Transactions** Wrap units of work within explicit transactions. If a unit of work spans multiple stored procedures, use savepoints within the called stored procedures, to mimic nested transactions by committing / rolling back the work done within each procedure. Without savepoints, a rollback of an inner transaction rolls back the entire transaction, and the outer procedures will need to check @@trancount to properly handle that. SQL Server does not support nested transactions.

**[Contents](https://github.com/CA-CST-SII/Software-Standards/blob/master/SQL%20Server%20Coding%20Standards.md#contents)** 
