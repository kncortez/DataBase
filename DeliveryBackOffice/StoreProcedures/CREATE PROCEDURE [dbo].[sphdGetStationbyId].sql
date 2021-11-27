-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		<Edwin Ramirez>
-- Create date: <2021-11-05>
-- Description:	<Devuelve todos los puntos de estacion servicio forza delivery>
-- =============================================
CREATE PROCEDURE sphdGetStationbyId
    -- Add the parameters for the stored procedure here
    @IdStation AS INT = -1,
    @IdCountry AS NVARCHAR(3) = 'all',
    @option AS INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF (@option = 0)
    BEGIN
        SELECT stn.IdStation [IdValue],
               CASE stn.StationType
                   WHEN 1 THEN
                       'FD HUB' + ' ' + UPPER(RTRIM(LTRIM(stn.StationName))) + ' - ['
                       + CAST(stn.HubLogisticId AS VARCHAR(10)) + ']'
                   WHEN 2 THEN
                       UPPER(RTRIM(LTRIM(stn.StationName))) + ' - [' + CAST(stn.CodeOfReference AS VARCHAR(10)) + ']'
                   ELSE
                       'FD' + UPPER(stn.StationName)
               END [NameValue],
               stn.CountryId [IdFilter],
               stn.StationType [IdType],
               stn.HubLogisticId [IdHub],   --FD HUBS
               stn.CodeOfReference [IdExc] --FD EXPRESS CENTER
        FROM DeliveryBackOffice.dbo.CatStation stn
        WHERE stn.RowStatus = 'TRUE'
              AND (@IdStation = -1 OR stn.IdStation = @IdStation)
              AND (@IdCountry = 'all' OR (CASE WHEN stn.CountryId IS NULL THEN 'all'ELSE stn.CountryId END) = @IdCountry)
        ORDER BY stn.StationType, stn.StationName;
    END;
END;
GO
