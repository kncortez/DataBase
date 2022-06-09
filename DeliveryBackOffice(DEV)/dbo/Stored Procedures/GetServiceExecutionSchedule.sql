-- =============================================
-- Author:		<Marco,Jimenez>
-- Create date: <2022-04-12>
-- Description:	<Stored Procedure para poder retornar si debe ejecutar el proceso de 
-- lote de diario, debido a que ya pasó el horario y aún no se ha ejecutado dicho lote>
-- =============================================
--EXEC dbo.GetServiceExecutionSchedule 'HermesWireTransfer','COD_Acumulado','14:47:58'
CREATE PROCEDURE [dbo].[GetServiceExecutionSchedule] 
@ServiceName AS VARCHAR(500),
@ProcessName AS VARCHAR(500),
@Time AS VARCHAR(250)

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RESULTID AS BIT;
	SET @RESULTID = 0;
	--DECLARE @Time AS VARCHAR(200) = '10:20:00';
	DECLARE @RowStatus AS BIT = 1;
	DECLARE @TimeSchedule AS VARCHAR(200);

	BEGIN TRY


		SELECT TOP 1
		@RESULTID = 1,
	    @TimeSchedule =  cs.Item
		FROM ServicesConfig sc
		CROSS APPLY dbo.DelimitedSplit8K(sc.TimeSchedule, ',') cs
		WHERE sc.ServiceProcess = @ProcessName
		AND sc.ServiceName = @ServiceName
		AND sc.RowStatus = @RowStatus
		AND NOT EXISTS (SELECT
				ssh.TimeSchedule
			FROM ScheduleServiceHistory ssh
			WHERE CAST(ssh.SSHDateCreated AS DATE) = CAST(GETDATE() AS DATE)
			AND ssh.SSHRowStatus = @RowStatus
			AND ssh.ServicesConfigId = sc.IdServicesConfig
			AND cs.Item = ssh.TimeSchedule
			AND ssh.LogType = 2)
		AND SUBSTRING(cs.Item, 1, 2) = SUBSTRING(@Time, 1, 2)
		AND CAST(cs.Item as TIME) <= CAST(@Time as TIME)
		ORDER BY cs.Item ASC

	END TRY
	BEGIN CATCH
		SELECT
			0 AS 'Result'
		   ,ERROR_MESSAGE() AS 'Description'

	END CATCH;

	IF @RESULTID > 0
	BEGIN

		SELECT
			@RESULTID AS 'Result'
		   ,'Se debe procesar el lote para el siguiente horario: ' + @TimeSchedule AS 'Description'
		   ,CONCAT(SUBSTRING(CAST(DATEADD(HH, -1, CAST(@TimeSchedule AS TIME)) AS VARCHAR(100)),1,8), ' a ' , @TimeSchedule ) AS TimeScheduleRange
		   ,@TimeSchedule AS TimeSchedule
	END
END