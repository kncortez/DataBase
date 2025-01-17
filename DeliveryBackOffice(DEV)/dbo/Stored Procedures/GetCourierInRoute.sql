
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-10-24>
-- Description: <Obtener el courier asignado a la ruta en caso exista >
-- =============================================
CREATE PROCEDURE [dbo].[GetCourierInRoute]
(
 @idRoute AS INT,
 @dateRoute AS DATE
)
AS
BEGIN
    DECLARE @IdCurrierMan INT
    IF EXISTS (SELECT IdCurrierMan
                 FROM [DeliveryBackOffice].[dbo].[RouteAssigment]
                WHERE IdRoute = @idRoute
                  AND DateOfRoute = @dateRoute
                  AND IdCurrierMan IS NOT NULL 
                )
    BEGIN
         SELECT @IdCurrierMan = IdCurrierMan
           FROM [DeliveryBackOffice].[dbo].[RouteAssigment]
          WHERE IdRoute = @idRoute
            AND DateOfRoute = @dateRoute
            AND IdCurrierMan IS NOT NULL 

         SELECT Phone AS [Phone]
           FROM SenderReceiver
          WHERE id = @IdCurrierMan
            AND Phone <> 0
            AND Phone IS NOT NULL
    END
    ELSE
    BEGIN
         SELECT '' AS [IdCurrierMan]
    END
END