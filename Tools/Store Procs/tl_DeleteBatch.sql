use [db_name]
GO
--==== Declares ====--
DECLARE @BatchSize INT = 500000,	--<< Set The Amount Of Data To Remove At A Time >>--  
		@counter BIGINT = 0

WHILE 1 = 1
BEGIN
	DELETE TOP (@BatchSize) protocolCustomValue
	FROM EVT_RawData rawData 
		INNER JOIN EVT_AlarmEvent alarmEvent ON rawData.rawDataID = alarmEvent.rawDataID
		INNER JOIN EVT_ProtocolCustomValue protocolCustomValue ON alarmEvent.eventID = protocolCustomValue.eventID
	WHERE rawData.recievedDTM <= DATEADD(MONTH, -3, CONVERT(DATETIME, '2020-04-20 15:25:37')) -- 335 415 974 {Batches - > 670,8} 
	IF @@ROWCOUNT < @BatchSize BREAK
	BEGIN
		SET @counter = @counter + 1		 
		PRINT '[Batch]:[' + CONVERT(VARCHAR(255),@counter) + ']'
		BEGIN
			WAITFOR DELAY '00:01';
		END
	END
END