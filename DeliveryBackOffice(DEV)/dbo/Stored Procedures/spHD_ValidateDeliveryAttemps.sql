-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-11-29>
-- Description:	<Obtiene listado de guías que no poseen reintentos de entrega y se marcan como devolución.>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_ValidateDeliveryAttemps]
    -- Add the parameters for the stored procedure here
    @DeliveryOrderBySettlementId BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @TblGuides AS TABLE
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT,
        FlowGuide TINYINT
    );

    DECLARE @StatusOrderDestroyed INT =
            (
                SELECT so.StatusOrderId
                FROM StatusOrder so
                WHERE so.OrderDescription = 'Paquete destruido'
            );
	DECLARE @STATUSDECLAREDRETURNED_DO INT = (SELECT TOP 1 SO.StatusOrderId FROM DBO.StatusOrder SO WITH(NOLOCK) WHERE OrderDescription = 'Declarado para Devolución');

    DECLARE @Active BIT = 'false';



    IF @Active = 'true'
    BEGIN
        BEGIN TRANSACTION;

        BEGIN TRY
            INSERT INTO @TblGuides
            SELECT dsd.Guide_Serie,
                   dsd.Guide_Number,
                   CASE
                       WHEN do.IsLastMileReturn = 1 THEN
                           CASE
                               WHEN
                               (
                                   SELECT COUNT(1)
                                   FROM DeliveryOrderDetail dod WITH (NOLOCK)
                                       INNER JOIN StatusOrder so WITH (NOLOCK)
                                           ON so.StatusOrderId = dod.StatusOrderId
                                   WHERE dod.RowStatus = 1
                                         AND dod.Guide_Serie = do.Guide_Serie
                                         AND dod.Guide_Number = do.Guide_Number
                                         AND so.OrderDescription = 'Intento de entrega fallida'
                               ) >=
                               (
                                   SELECT TOP 1
                                          ISNULL(rh.Attempt, 2) + rh.AttemptReturn
                                   FROM RateHeader rh WITH (NOLOCK)
                                       LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
                                           ON vpc.CodeOfReference = do.Sender_ID
                                       INNER JOIN RatebyCustomer rc WITH (NOLOCK)
                                           ON rc.RbcIdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                                              AND
                                              (
                                                  rc.RbcCodeOfReference IS NULL
                                                  OR rc.RbcCodeOfReference = do.Sender_ID
                                              )
                                   WHERE rh.RheId = rc.RbcIdRate
                                   ORDER BY rc.RbcCodeOfReference DESC
                               ) THEN
                                   CASE 
										WHEN 
										NOT EXISTS(
											SELECT
												1
											FROM ConfirmationOfIncidence coi
											INNER JOIN DeliveryAttempt da WITH (NOLOCK)
												ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
												AND da.Guide_Serie = dsd.Guide_Serie
												AND da.Guide_Number = dsd.Guide_Number
												AND da.ID_DeliveryOrderBySettlement = dsd.ID_DeliveryOrderBySettlement
												WHERE coi.ClientConfirmsReturn = 1
										) THEN
											3 --'IsBazar'
										ELSE 4 --'IsReturn'
									END
                               ELSE
                                   4 --'IsReturn'
                           END
                       ELSE
                           CASE
                               WHEN
                               (
                                   SELECT COUNT(1)
                                   FROM DeliveryOrderDetail dod WITH (NOLOCK)
                                       INNER JOIN StatusOrder so WITH (NOLOCK)
                                           ON so.StatusOrderId = dod.StatusOrderId
                                   WHERE dod.RowStatus = 1
                                         AND dod.Guide_Serie = do.Guide_Serie
                                         AND dod.Guide_Number = do.Guide_Number
                                         AND so.OrderDescription = 'Intento de entrega fallida'
                               ) >= ISNULL(
                                    (
                                        SELECT TOP 1
                                               rh.Attempt
                                        FROM RateHeader rh WITH (NOLOCK)
                                            LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
                                                ON vpc.CodeOfReference = do.Sender_ID
                                            INNER JOIN RatebyCustomer rc WITH (NOLOCK)
                                                ON rc.RbcIdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                                                   AND
                                                   (
                                                       rc.RbcCodeOfReference IS NULL
                                                       OR rc.RbcCodeOfReference = do.Sender_ID
                                                   )
                                                   AND rc.RbcRowStatus = 1
                                        WHERE rh.RheId = rc.RbcIdRate
                                        ORDER BY rc.RbcCodeOfReference DESC
                                    ),
                                    2
                                          ) THEN
                                   2 --'IsReturn'
                               ELSE
                                   1 --'IsDelivery'
                           END
                   END FlowGuide
            FROM DeliverySettlementDetail dsd WITH (NOLOCK)
                INNER JOIN DeliveryOrder do WITH (NOLOCK)
                    ON dsd.Guide_Serie = do.Guide_Serie
                       AND dsd.Guide_Number = do.Guide_Number
            WHERE dsd.ID_DeliveryOrderBySettlement = @DeliveryOrderBySettlementId
                  AND dsd.RowStatus = 1
                  AND dsd.Guide_Returned = 1;


            -- Marcar las que ya no tienen intentos de entrega disponibles como devolución
            UPDATE do
            SET do.IsLastMileReturn = 1,
				do.StatusOrderId = @STATUSDECLAREDRETURNED_DO
            FROM DeliveryOrder do
                INNER JOIN @TblGuides tg
                    ON do.Guide_Serie = tg.GuideSerie
                       AND do.Guide_Number = tg.GuideNumber
            WHERE tg.FlowGuide = 2;

			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
				(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, RowStatus)
			SELECT
				DISTINCT
					tg.GuideSerie, tg.GuideNumber, @STATUSDECLAREDRETURNED_DO, 'spHD_ValidateDeliveryAttemps', GETDATE(), GETDATE(), 1
			FROM @TblGuides tg
            WHERE tg.FlowGuide = 2;

            COMMIT TRANSACTION;

            SELECT 1 'StatusCode',
                   'Registros obtenidos correctamente.' 'Description';

            SELECT GuideSerie Guide_Serie,
                   GuideNumber Guide_Number
            FROM @TblGuides
            WHERE FlowGuide = 2;

        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;

            SELECT 0 'StatusCode',
                   ERROR_MESSAGE() 'Description';
        END CATCH;

    END;

    ELSE
    BEGIN



        SELECT 1 'StatusCode',
               'Registros obtenidos correctamente.' 'Description';

			    SELECT GuideSerie Guide_Serie,
                   GuideNumber Guide_Number
            FROM @TblGuides
            WHERE FlowGuide = 2;
				 
			 
    END;
END;