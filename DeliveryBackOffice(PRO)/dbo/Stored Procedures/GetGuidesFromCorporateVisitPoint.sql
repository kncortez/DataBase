

-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-03-29>
-- Description:	< Obtiene listado de guias estado solicitado recoleccion Hermes Web Corporativo >
-- =============================================

CREATE PROCEDURE [dbo].[GetGuidesFromCorporateVisitPoint]
    @StartDate DATE,     -- fecha de inicio de busqueda.
    @EndDate DATE,       -- fecha de finalizacion de busqueda.
    @IdAccount BIGINT,   -- ID de cuenta de usuario que consulta.
    @Token NVARCHAR(50), -- Token usuario que consulta.
    @CodeOfReference INT -- Punto a consultar.

AS
BEGIN


    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @GuidesData NVARCHAR(MAX);


    SET @GuidesData =
    (
        SELECT STUFF(
                        (
                            SELECT ',{' + '"OrderSerie":"' + do.Guide_Serie + '",' + '"OrderNumber":"'
                                   + CONVERT(NVARCHAR(MAX), do.Guide_Number) + '",' + '"ReceiverName":"'
                                   + CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) + '",'
                                   + '"ServiceType":"'
                                   + IIF(do.TypeService = 'NDD' OR do.TypeService = 'TDA', 'NEXT DAY', 'SAME DAY')
                                   + '",' + '"Price":' + CONVERT(NVARCHAR(MAX), ISNULL(do.PriceShippment, 0)) + ','
                                   + '"COD":' + CONVERT(NVARCHAR(MAX), ISNULL(do.Collect_OnDelivery, 0)) + ','
                                   + '"Pieces":'
                                   + CONVERT(NVARCHAR(MAX), ISNULL(do.Pieces_Cold, 0) + ISNULL(do.Pieces_Dry, 0)) + ','
                                   + '"ColdPieces":' + CONVERT(NVARCHAR(MAX), ISNULL(do.Pieces_Cold, 0)) + ','
                                   + '"DryPieces":' + CONVERT(NVARCHAR(MAX), ISNULL(do.Pieces_Dry, 0)) + '' + '}'
                            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                                LEFT JOIN DeliveryBackOffice.dbo.CorporateManifestDetail cmd
                                    ON cmd.GuideNumber = do.Guide_Number
                                       AND cmd.GuideSerie = do.Guide_Serie
                                       AND cmd.RowStatus = 1
                            WHERE do.StatusOrderId = 1
                                  AND do.Sender_ID = @CodeOfReference
                                  AND do.IsReturn = 0
                                  AND (CONVERT(DATE, do.DateCreated)
                                  BETWEEN @StartDate AND @EndDate
                                      )
                                  AND cmd.GuideNumber IS NULL
                            FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'),
                        1,
                        1,
                        ''
                    )
    );



    IF (@GuidesData IS NOT NULL)
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{									
								"Guides":[' + @GuidesData + '],' + '"Status": 200' + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    ELSE
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{									
								"Message":"No se encontraron guías en el rango de fecha seleccionado.",'
                                       + '"Status": 400' + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;



    SELECT ('[' + @jsonResult + ']') jsonResult;

END;
