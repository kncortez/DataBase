-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-07-01>
-- Description:	<Método para eliminar guías del contenedor>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_RemoveGuidesContainer]
@ReferenceContainer NVARCHAR(14),
@TblContainerGuides AS TblContainerGuides READONLY,
@IdCustomer INT,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    DECLARE @IdContainer BIGINT;
    DECLARE @StatusContainer INT; 
    SELECT  @IdContainer = IdContainer,
            @StatusContainer = IdStatusContainer 
      FROM [dbo].[ShippingContainer] WITH(NOLOCK)
     WHERE ReferenceContainer = @ReferenceContainer AND IdCustomer = @IdCustomer;
    
    IF (@IdContainer IS NULL)
    BEGIN 
        SELECT 0 AS [StatusCode], 'El contenedor ingresado no existe o no corresponde al usuario que está intentando eliminar guías. Verifica el nombre del contenedor e ingresa uno válido que esté asociado a tu usuario.' AS [Message]
    END
    ELSE 
    BEGIN
        IF @StatusContainer != 5 -- Valida que el contenedor no se encuentre liquidado
        BEGIN
            BEGIN TRANSACTION
            BEGIN TRY
                --Toma los valores de entrada
                SELECT GuideSerie, GuideNumber, TicketNumber, IdCustomer, StatusOrder = 0 
                INTO #Guides
                FROM @TblContainerGuides;

                CREATE NONCLUSTERED INDEX IX_TempCont_SerieNumber ON #Guides(GuideSerie, GuideNumber);
                CREATE NONCLUSTERED INDEX IX_TempCont_Customer ON #Guides(IdCustomer);
                CREATE NONCLUSTERED INDEX IX_TempCont_Status ON #Guides(StatusOrder);

                -- Actualizar GuideSerie y GuideNumber si coinciden con TicketNumber
                UPDATE G
                SET G.GuideSerie = O.Guide_Serie,
                    G.GuideNumber = O.Guide_Number,
                    G.IdCustomer = O.IdCustomer
                FROM #Guides G
                CROSS APPLY (
                    SELECT TOP 1 Guide_Serie, Guide_Number, IdCustomer
                    FROM DeliveryOrder O WITH(NOLOCK)
                    WHERE O.IdCustomer = G.IdCustomer
                    AND O.Ticket_Number = G.TicketNumber
                    ORDER BY O.DateCreated DESC
                ) O
                WHERE G.GuideSerie = N'' OR G.GuideNumber = 0;

                UPDATE G
                SET G.TicketNumber = O.Ticket_Number,
                    G.StatusOrder = O.StatusOrderId,
                    G.IdCustomer = O.IdCustomer
                FROM #Guides G
                CROSS APPLY (
                    SELECT TOP 1 Ticket_Number, StatusOrderId, IdCustomer
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
                    SELECT 0 AS [StatusCode], 'Las guías que intentas eliminar no están en un estado que permita esta acción. Solo puedes eliminar guías que estén en los estados "Generado" o "Solicitado". Revisa el estado de las guías antes de continuar.' AS [Message]
                END
                ELSE IF NOT EXISTS (SELECT 1 FROM #Guides T
                                WHERE EXISTS (
                                    SELECT 1
                                    FROM ShippingContainerDetail D WITH(NOLOCK)
                                    WHERE T.GuideNumber = D.GuideNumber AND T.GuideSerie = D.GuideSerie AND D.RowStatus = 1 AND D.IdContainer = @IdContainer
                                )
                )
                BEGIN
                    SELECT 0 AS [StatusCode], 'La guía que intentas eliminar no está asociada al contenedor seleccionado. Verifica el número de guía y asegúrate de que pertenece al contenedor correcto antes de intentar nuevamente.' AS [Message]
                END
                ELSE
                BEGIN
                    UPDATE ShippingContainerDetail
                    SET UserUpdated = @User,
                        DateUpdated = GETDATE(),
                        TokenUpdated = @Token,
                        RowStatus = 0
                    FROM #Guides AS gUP
                    WHERE ShippingContainerDetail.GuideNumber = gUP.GuideNumber AND ShippingContainerDetail.GuideSerie = gUP.GuideSerie;

                    DECLARE @CountGuides INT = (SELECT COUNT(1) FROM ShippingContainerDetail WITH(NOLOCK) WHERE IdContainer = @IdContainer AND RowStatus = 1);
                    
                    IF @@TRANCOUNT > 0
                    BEGIN
                        SELECT 1 AS [StatusCode], 'Guías eliminadas exitosamente' AS [Message]
                        UPDATE [dbo].[ShippingContainer] 
                        SET CountGuides = @CountGuides
                        WHERE IdContainer = @IdContainer
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
                            ,'Error eliminación de guías del contenedor'
                            ,GETDATE())

            END CATCH;
        END
        ELSE -- El contenedor se encuentra liquidado
        BEGIN
            SELECT 0 AS [StatusCode], 'El contenedor que intentas gestionar ya ha sido liquidado y no permite nuevas transacciones. Por favor, verifica que el contenedor ingresado sea correcto.' AS [Message]
        END
    END
    
END;