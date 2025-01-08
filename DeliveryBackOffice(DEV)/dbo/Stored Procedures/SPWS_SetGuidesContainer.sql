-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-03-01>
-- Description:	<Método para agregar guías al contenedor>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_SetGuidesContainer]
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
    FROM [dbo].[ShippingContainer] WHERE ReferenceContainer = @ReferenceContainer AND IdCustomer = @IdCustomer;
    -- Si no existe el contenedor, se crea uno nuevo
    IF (@IdContainer IS NULL)
    BEGIN 
        INSERT INTO [dbo].[ShippingContainer] (ReferenceContainer, IdCustomer, IdStatusContainer, CountGuides, UserCreated, DateCreated, TokenCreated) 
        VALUES (@ReferenceContainer, @IdCustomer, 1, 0, @User, GETDATE(), @Token);
        SET @IdContainer = SCOPE_IDENTITY();
        SET @StatusContainer = 1; --Estado generado
    END
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
                SELECT 0 AS [StatusCode], 'Las guías que intentas asociar no están vinculadas al usuario que realiza esta transacción. Asegúrate de que las guías hayan sido creadas con tu usuario antes de continuar.' AS [Message]
            END
            ELSE IF EXISTS (SELECT 1 FROM #Guides WHERE StatusOrder != 15 AND StatusOrder != 1)
            BEGIN
                SELECT 0 AS [StatusCode], 'Las guías que intentas asociar no están en un estado que permita esta acción. Solo puedes asociar guías que estén en los estados "Generado" o "Solicitado". Revisa el estado de las guías antes de continuar.' AS [Message]
            END
            ELSE IF EXISTS (SELECT 1 FROM #Guides T
                            WHERE EXISTS (
                                SELECT 1
                                FROM ShippingContainerDetail D
                                WHERE T.GuideNumber = D.GuideNumber AND T.GuideSerie = D.GuideSerie AND D.RowStatus = 1
                            )
            )
            BEGIN
                SELECT 0 AS [StatusCode], 'Las guías que intentas asociar ya están vinculadas a un contenedor.' AS [Message]
            END
            ELSE
            BEGIN
                -- Actualiza guías existentes pero eliminadas
                UPDATE ShippingContainerDetail
                SET IdContainer = @IdContainer, 
                    UserUpdated = @User,
                    DateUpdated = GETDATE(),
                    TokenUpdated = @Token,
                    RowStatus = 1
                FROM #Guides AS gUP
                WHERE ShippingContainerDetail.GuideNumber = gUP.GuideNumber AND ShippingContainerDetail.GuideSerie = gUP.GuideSerie AND RowStatus = 0;

                -- Agrega guías nuevas al contenedor
                INSERT INTO [dbo].[ShippingContainerDetail] (IdContainer, GuideSerie, GuideNumber, TicketNumber, UserCreated, DateCreated, TokenCreated)
                SELECT @IdContainer, GuideSerie, GuideNumber, TicketNumber, @User, GETDATE(), @Token FROM #Guides g
                WHERE NOT EXISTS (SELECT GuideNumber FROM [dbo].[ShippingContainerDetail] scd WHERE scd.GuideSerie = g.GuideSerie AND scd.GuideNumber = g.GuideNumber);

                DECLARE @CountGuides INT = (SELECT COUNT(1) FROM ShippingContainerDetail WHERE IdContainer = @IdContainer AND RowStatus = 1);
                
                IF @@TRANCOUNT > 0
                BEGIN
                    SELECT 1 AS [StatusCode], 'Guías agregadas exitosamente' AS [Message]
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
                        ,'Error creación de contenedor'
                        ,GETDATE())

        END CATCH;
    END
    ELSE -- El contenedor se encuentra liquidado
    BEGIN
        SELECT 0 AS [StatusCode], 'El contenedor que intentas gestionar ya ha sido liquidado y no permite nuevas transacciones. Por favor, verifica que el contenedor ingresado sea correcto.' AS [Message]
    END
END;