-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-11-29>
-- Description:	<Obtiene listado de guías que no poseen reintentos de entrega y se marcan como devolución.>
-- =============================================
CREATE procedure [dbo].[spHD_ValidateDeliveryAttemps]
    -- Add the parameters for the stored procedure here
    @DeliveryOrderBySettlementId bigint
as
begin
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    set NOCOUNT ON;

	-- Tabla de incidencias forzadas a devolución
	DECLARE @ReturnIncidence TABLE 
	(
		IncidenceId INT
	);

    -- Insert statements for procedure here
    DECLARE @TblGuides AS TABLE
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT,
        FlowGuide TINYINT
    );

	INSERT INTO @ReturnIncidence
	(
	    [IncidenceId]
	)
	SELECT
		[CTI].[IdIncidenceType]
	FROM
		[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) 
	WHERE
		[CTI].[NameIncidence] = 'Destinatario rechaza paquete'  COLLATE Latin1_General_CI_AI 
		AND
		[CTI].[RowStatus] = 1
		AND
		[CTI].[ServiceType] = 'DELIVERY'  COLLATE Latin1_General_CI_AI 

	INSERT INTO @ReturnIncidence
	(
	    [IncidenceId]
	)
	SELECT
		[CTI].[IdIncidenceType]
	FROM
		[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) 
	WHERE
		[CTI].[NameIncidence] = 'Remitente solicita devolución'  COLLATE Latin1_General_CI_AI 
		AND
		[CTI].[RowStatus] = 1
		AND
		[CTI].[ServiceType] = 'DELIVERY'  COLLATE Latin1_General_CI_AI 


	DECLARE @STATUSDECLAREDRETURNED_DO INT = (SELECT TOP 1 SO.StatusOrderId FROM DBO.StatusOrder SO WITH(NOLOCK) WHERE OrderDescription = 'Declarado para Devolución');

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO @TblGuides
        SELECT DISTINCT
            dsd.Guide_Serie
            ,dsd.Guide_Number
            ,CASE
                WHEN do.IsLastMileReturn IS NULL OR do.IsLastMileReturn = 0 THEN CASE
                        WHEN doad.GuideDeliveryAttemptCount >= doad.GuideDeliveryMaxAttemptCount OR coi.ClientConfirmsReturn = 1 THEN 2
						WHEN [da].[ID_Incident] IN (SELECT [RI].[IncidenceId] FROM @ReturnIncidence RI) THEN 2
                        ELSE 1
                    END
                ELSE 1
            END
            FlowGuide
        FROM DeliverySettlementDetail dsd WITH (NOLOCK)
        INNER JOIN DeliveryOrder do WITH (NOLOCK)
            ON dsd.Guide_Serie = do.Guide_Serie
                AND dsd.Guide_Number = do.Guide_Number
        INNER JOIN DeliveryOrderAttemptData doad WITH (NOLOCK)
            ON dsd.Guide_Serie = doad.GuideSerie
                AND dsd.Guide_Number = doad.GuideNumber
                AND doad.RowStatus = 1
        INNER JOIN DeliveryAttempt da WITH(NOLOCK)
        ON dsd.Guide_Serie = da.Guide_Serie
                AND dsd.Guide_Number = da.Guide_Number
                AND da.ID_DeliveryOrderBySettlement = dsd.ID_DeliveryOrderBySettlement
        LEFT JOIN ConfirmationOfIncidence coi WITH(NOLOCK)
        ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
        WHERE dsd.ID_DeliveryOrderBySettlement = @DeliveryOrderBySettlementId
        AND dsd.RowStatus = 1
        AND dsd.Guide_Returned = 1


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
        WHERE FlowGuide = 2
       
                  

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT 0 'StatusCode',
                ERROR_MESSAGE() 'Description';
    END CATCH;
END;