-- =============================================
-- Author:		<Edelman V>
-- Create date: <2022-10-10>
-- Description:	<SP para Validar estado de guia para marcar como devuleto>
-- =============================================
-- =============================================
-- Author:		<Edelman V>
-- Create date: <2022-10-10>
-- Description:	<Validaciones de datos de guía antes de devolución>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidateGuideStatus] @Guide AS NVARCHAR(20)
AS
BEGIN
    DECLARE @STATUS AS INT;
    DECLARE @Sender_Department AS NVARCHAR(150);
    DECLARE @Receiver_Department AS NVARCHAR(150);
    DECLARE @Sender_Town AS INT;
    DECLARE @Receiver_Town AS INT;
	DECLARE @ClientConfirmsReturn AS bit = 0;

    DECLARE @Entregado INT =
            (
                SELECT [StatusOrderId]
                FROM [dbo].[StatusOrder] WITH (NOLOCK)
                WHERE [OrderDescription] = 'Entregado'
            );
    DECLARE @Anulado INT =
            (
                SELECT [StatusOrderId]
                FROM [dbo].[StatusOrder] WITH (NOLOCK)
                WHERE [OrderDescription] = 'Anulado'
            );
    DECLARE @Devuelto INT =
            (
                SELECT [StatusOrderId]
                FROM [dbo].[StatusOrder] WITH (NOLOCK)
                WHERE [OrderDescription] = 'Devuelto'
            );
    DECLARE @EntregadoEnExpressCenter INT =
            (
                SELECT [StatusOrderId]
                FROM [dbo].[StatusOrder] WITH (NOLOCK)
                WHERE [OrderDescription] = 'Entregado En Express Center'
            );
    DECLARE @Terminal INT =
            (
                SELECT [SO].[StatusOrderId]
                FROM [dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
                    INNER JOIN [dbo].[StatusOrder] [SO] WITH (NOLOCK)
                        ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
                WHERE [CatCheckpointTypeId] = 3
                      AND [SO].[RowStatus] = 1
                      AND [DO].[Guide_Serie] + CAST([DO].[Guide_Number] AS NVARCHAR(20)) = @Guide
            );

    DECLARE @RESULT INT = 0;
    DECLARE @StatusName NVARCHAR(100);

    DECLARE @DateStatus DATETIME =
            (
                SELECT TOP 1
                       [DOD].[DateCreated]
                FROM [dbo].[DeliveryOrderDetail] [DOD] WITH (NOLOCK)
                WHERE [DOD].[Guide_Serie] + CAST([DOD].[Guide_Number] AS NVARCHAR(20)) = @Guide
                ORDER BY [DOD].[DateCreated] DESC
            );

	DECLARE @Incidentsavailable INT = 0 --AL HABILITAR CÓDIGO QUITAR ESTO
 --   DECLARE @Incidentsavailable INT = (
	
	--		 Select ISNULL([DOAD].[GuideDeliveryMaxAttemptCount],0) -ISNULL([DOAD].[GuideDeliveryAttemptCount],0) 
	--			From [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD WITH (NOLOCK)
	--		 Where 
	--		DOAD.GuideSerie+ Convert(NVARCHAR(20),DOAD.GuideNumber) =  @Guide
	--        );

	----No importando la cantidad de intentos disponibles si el cliente ya no quiere 
	----el servicio se permite declarar para devolución
	--SET @ClientConfirmsReturn = (SELECT TOP 1 a2.ClientConfirmsReturn 
	--FROM DeliveryBackOffice.dbo.DeliveryAttempt A1 WITH(NOLOCK)
	--INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence A2 WITH(NOLOCK)
	--ON A2.IdConfirmationOfIncidence = A1.ConfirmationOfIncidenceId
	--WHERE A1.Guide_Serie+ Convert(NVARCHAR(20),A1.Guide_Number) =  @Guide
	--AND A2.ClientConfirmsReturn = 1
	--)
		
	--IF (@ClientConfirmsReturn =1 )
	--BEGIN
	-- SET @Incidentsavailable = 0
	--END 


    SET NOCOUNT ON;

    BEGIN TRY



        SELECT @STATUS = [DO].[StatusOrderId],
               @Sender_Department = [Sender_Department],
               @Receiver_Department = [Receiver_Department],
               @Sender_Town = [SenderIdTownship],
               @Receiver_Town = [ReceiverIdTownship],
               @StatusName = [SO].[OrderDescription]
        FROM [dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
            INNER JOIN [dbo].[StatusOrder] [SO] WITH (NOLOCK)
                ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
        WHERE [Guide_Serie] + CAST([Guide_Number] AS NVARCHAR) = @Guide;

        DECLARE @isreturnt BIT =
                (
                    SELECT [IsLastMileReturn]
                    FROM [dbo].[DeliveryOrder] WITH (NOLOCK)
                    WHERE [Guide_Serie] + CAST([Guide_Number] AS NVARCHAR) = @Guide
                );

        IF (EXISTS
        (
            SELECT TOP 1
                   1
            FROM [dbo].[DeliveryOrder] [DDO] WITH (NOLOCK)
                INNER JOIN [dbo].[DeliveryOrderPiece] [DOP] WITH (NOLOCK)
                    ON [DDO].[Guide_Number] = [DOP].[GuideNumber]
            WHERE [DDO].[Guide_Serie] + CAST([DDO].[Guide_Number] AS NVARCHAR) = @Guide
        )
           )
        BEGIN

            IF (@STATUS IN ( @Entregado, @Anulado, @EntregadoEnExpressCenter, @Terminal ))
            BEGIN

                SELECT [Result] = 1,
                       @StatusName 'Status',
                       CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus'; /* Estados no validos*/
            END;
            ELSE IF (@isreturnt = 1)
            BEGIN

                SELECT [Result] = 6,
                       @StatusName 'Status',
                       CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus'; /* Estados Devuelto*/

            END;
            ELSE
            BEGIN

                 SELECT CASE WHEN @Incidentsavailable > 0  THEN  7 
				         ELSE
				         0 END [Result],
                       @StatusName 'Status',
                       CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus';
            END;

        END;
        ELSE
        BEGIN

            SELECT [Result] = 3,
                   @StatusName 'Status',
                   CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus'; /* Guía no existe*/
        END;



    END TRY
    BEGIN CATCH

        SELECT [Result] = 4, /*Error de transacción*/
               ERROR_MESSAGE() AS 'Description';
    END CATCH;
END;