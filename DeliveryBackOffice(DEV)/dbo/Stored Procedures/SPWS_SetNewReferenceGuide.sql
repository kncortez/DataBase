-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-07-01>
-- Description:	<Método para actualizar referencia de guía>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_SetNewReferenceGuide]
@TblNewReferenceGuides AS TblNewReferenceGuides READONLY,
@IdCustomer INT,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    DECLARE @IdContainer BIGINT;
    DECLARE @StatusContainer INT; 
    SELECT  @IdContainer = IdContainer,
            @StatusContainer = IdStatusContainer 
    FROM [dbo].[ShippingContainer] WHERE ReferenceContainer = @ReferenceContainer AND IdCustomer = @IdCustomer;
    
    BEGIN TRANSACTION
            BEGIN TRY
                --Toma los valores de entrada
                SELECT GuideSerie, GuideNumber, StatusOrder = 0, IdCustomer = 0
                INTO #Guides
                FROM @TblContainerGuides;

                UPDATE G
                SET G.StatusOrder = O.StatusOrderId,
                    G.IdCustomer = O.IdCustomer
                FROM #Guides G
                CROSS APPLY (
                    SELECT TOP 1 StatusOrderId, IdCustomer
                    FROM DeliveryOrder O WITH(NOLOCK)
                    WHERE O.Guide_Serie = G.GuideSerie
                    AND O.Guide_Number = G.GuideNumber
                ) O;
                
                -- Valida que las guías correspondan al cliente y se encuentren en el estado correcto
                IF EXISTS (SELECT 1 FROM #Guides WHERE IdCustomer != @IdCustomer)
                BEGIN
                    SELECT 0 AS [StatusCode], 'Las guías que intentas eliminar no están vinculadas al usuario que realiza esta transacción. Asegúrate de que las guías hayan sido creadas con tu usuario antes de continuar.' AS [Message]
                END
                ELSE IF EXISTS (SELECT 1 FROM #Guides WHERE StatusOrder != 15 AND StatusOrder != 1)
                BEGIN
                    SELECT 0 AS [StatusCode], 'Las guías que intentas modificar no están vinculadas al usuario que realiza esta transacción. Asegúrate de que las guías hayan sido creadas con tu usuario antes de continuar.' AS [Message]
                END
                ELSE
                BEGIN
                    -- Actualiza guías existentes pero eliminadas
                    UPDATE DeliveryOrder
                    SET Ticket_Number = gUP.TicketNumber,
                    FROM #Guides AS gUP
                    WHERE Guide_Number = gUP.GuideNumber AND Guide_Serie = gUP.GuideSerie;
                    
                    IF @@TRANCOUNT > 0
                    BEGIN
                        SELECT 1 AS [StatusCode], 'Guías actualizadas exitosamente' AS [Message]
                    END
                END
                COMMIT TRANSACTION;
                DROP TABLE #Guides
            END TRY
            BEGIN CATCH
                SELECT 0 AS [StatusCode], ERROR_MESSAGE() AS [Message]

                ROLLBACK TRANSACTION
                    INSERT INTO dbo.RoutePreparationLogError
                    (
                        ErrorDescription,
                        ErrorNumber,
                        ErrorProcedure,
                        ErrorLine,
                        GuideSerie,
                        GuideNumber,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (CAST(ERROR_MESSAGE() AS VARCHAR(300))
                            ,ERROR_NUMBER()
                            ,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
                            ,ERROR_LINE()
                            ,0
                            ,0
                            ,'Error en actualización de guías'
                            ,GETDATE())

            END CATCH;
    
END;