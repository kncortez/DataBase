-- =============================================
-- Author:		<Marco,Jimenez>
-- Create date: <2021-07-16>
-- Description:	<Inserta log de ejecución del servicio de HermesWireTransfer>
-- =============================================
--EXEC SetServiceExecutionLog 'COD BATCH', 'Proceso genarador de lotes y de archivos csv, xlsx cada 2 horas para COD',1,'SYS-HERMESWIRETRANSFER'
CREATE PROCEDURE [dbo].[SetServiceExecutionLog]
    @name AS NVARCHAR(400),
    @description AS NVARCHAR(600),
    @status AS VARCHAR(1),
    @token AS NVARCHAR(MAX),
    @time AS NVARCHAR(250) = '00:00:00',
    @ProcessName AS VARCHAR(500) = 'DEFAULT',
    @Type AS INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RESULTID AS INT;
    SET @RESULTID = 0;
    BEGIN TRANSACTION;
    BEGIN TRY


        INSERT INTO ScheduleServiceHistory
        VALUES
        (   @name, @description, CAST(@status AS INT), @token, GETDATE(), NULL, NULL, @time,
            (
                SELECT sc.IdServicesConfig
                FROM ServicesConfig sc WITH (NOLOCK)
                WHERE sc.ServiceProcess = @ProcessName
            ), @Type);
        SET @RESULTID = @@identity;


    END TRY
    BEGIN CATCH
        SELECT 0 AS 'ID',
               ERROR_MESSAGE() AS 'Description';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@trancount > 0
    BEGIN
        COMMIT TRANSACTION;
        SELECT @RESULTID AS 'ID',
               'Registros guardados correctamente' AS 'Description';
    END;
END;