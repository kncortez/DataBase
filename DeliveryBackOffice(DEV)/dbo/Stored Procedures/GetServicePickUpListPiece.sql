-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-10-14>
-- Description:	<Lista los servicios con las piezas que se deben de escanear>
-- =============================================
CREATE PROCEDURE [dbo].[GetServicePickUpListPiece]
    @IdCourier INT = 2513,
    @DateRoute DATE = '2024-10-08',
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    BEGIN TRY
        DECLARE @StatusRecolect INT = (
                                          SELECT IdServiceStatus FROM CatServiceStatus WHERE Name = 'Recolectado'
                                      )
        IF EXISTS
        (
            SELECT TOP 1
                1
            FROM dbo.RouteAssigment ras WITH (NOLOCK)
                INNER JOIN dbo.ServiceManagement sma WITH (NOLOCK)
                    ON sma.IdPuRouteAssigment = ras.IdRouteAssigment
                INNER JOIN dbo.SchedulePickup spk WITH (NOLOCK)
                    ON spk.SchedulePickupId = sma.IdSchedulePickup
                LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = spk.SenderId
            WHERE ras.IdCurrierMan = @IdCourier
                  AND ras.DateOfRoute = @DateRoute
                  AND sma.ServiceStatusId = @StatusRecolect
                  AND vpc.CountryId = @IdCountry
        )
        BEGIN
            SELECT 200 AS StatusCode,
                   'Servicio encontrado' AS Message

            SELECT spk.SchedulePickupId,
                   spk.SenderName,
                   spk.AddressPickup,
                   1 AS TypeofInOutMoneyId,
                   sma.IdServiceManagement
            FROM dbo.RouteAssigment ras WITH (NOLOCK)
                INNER JOIN dbo.ServiceManagement sma WITH (NOLOCK)
                    ON sma.IdPuRouteAssigment = ras.IdRouteAssigment
                INNER JOIN dbo.SchedulePickup spk WITH (NOLOCK)
                    ON spk.SchedulePickupId = sma.IdSchedulePickup
                LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = spk.SenderId
            WHERE ras.IdCurrierMan = @IdCourier
                  AND ras.DateOfRoute = @DateRoute
                  AND sma.ServiceStatusId = @StatusRecolect
                  AND vpc.CountryId = @IdCountry

        END
        ELSE
        BEGIN
            SELECT 0 AS StatusCode,
                   'Servicio no encontrado o en estado recolectado' AS Message
        END
    END TRY
    BEGIN CATCH
        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Message,
               ERROR_LINE() AS ErrorLine
    END CATCH
END