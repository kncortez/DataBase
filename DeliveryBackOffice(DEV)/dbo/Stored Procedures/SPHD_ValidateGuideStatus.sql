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
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <2024-05-28>
-- Description:	<Se agrega parametro para filtrar por pais de origen de la guia>
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <2024-06-24>
-- Description:	<Se agrega validacion para saber si la guia es domestica o internacional>
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <2024-12-11>
-- Description:	<Se agrega campo de nombre de cliente asociado a la guía>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidateGuideStatus] @Guide AS NVARCHAR(20),
	@IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN
    DECLARE @STATUS AS INT;
    DECLARE @Sender_Department AS NVARCHAR(150);
    DECLARE @Receiver_Department AS NVARCHAR(150);
    DECLARE @Sender_Town AS INT;
    DECLARE @Receiver_Town AS INT;
	DECLARE @ClientConfirmsReturn AS bit = 0;
    DECLARE @ExistRegister AS BIT = 0;
    DECLARE @GuideSerie VARCHAR(50);
	DECLARE @GuideNumber VARCHAR(50);
    DECLARE @ExistRegisterInAnotherCountry AS BIT = 0;
    DECLARE @CustomerName AS NVARCHAR(500) = '';

	-- Extraer letras
		SET @GuideSerie = '';
		SELECT @GuideSerie = @GuideSerie + letra
		FROM (
			SELECT SUBSTRING(@Guide, number, 1) AS letra
			FROM master..spt_values
			WHERE type = 'P' AND number BETWEEN 1 AND LEN(@Guide)
			AND SUBSTRING(@Guide, number, 1) LIKE '[A-Za-z]'
		) AS letras;

		-- Extraer números
		SET @GuideNumber = '';
		SELECT @GuideNumber = @GuideNumber + numero
		FROM (
			SELECT SUBSTRING(@Guide, number, 1) AS numero
			FROM master..spt_values
			WHERE type = 'P' AND number BETWEEN 1 AND LEN(@Guide)
			AND SUBSTRING(@Guide, number, 1) LIKE '[0-9]'
		) AS numeros;

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
                      AND [DO].[Guide_Serie] = @GuideSerie AND [DO].[Guide_Number] = @GuideNumber 
            );

    DECLARE @RESULT INT = 0;
    DECLARE @StatusName NVARCHAR(100);

    DECLARE @DateStatus DATETIME =
            (
                SELECT TOP 1
                       [DOD].[DateCreated]
                FROM [dbo].[DeliveryOrderDetail] [DOD] WITH (NOLOCK)
                WHERE [DOD].[Guide_Serie] = @GuideSerie AND [DOD].[Guide_Number] = @GuideNumber 
                ORDER BY [DOD].[DateCreated] DESC
            );

	
    DECLARE @Incidentsavailable INT = (
	
			 Select ISNULL([DOAD].[GuideDeliveryMaxAttemptCount],0) -ISNULL([DOAD].[GuideDeliveryAttemptCount],0) 
				From [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD WITH (NOLOCK)
			 Where 
             [DOAD].[GuideSerie] = @GuideSerie AND [DOAD].[GuideNumber] = @GuideNumber 
	        );

	----No importando la cantidad de intentos disponibles si el cliente ya no quiere 
	----el servicio se permite declarar para devolución
	SET @ClientConfirmsReturn = (SELECT TOP 1 a2.ClientConfirmsReturn 
										FROM DeliveryBackOffice.dbo.DeliveryAttempt A1 WITH(NOLOCK)
										INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence A2 WITH(NOLOCK)
										ON A2.IdConfirmationOfIncidence = A1.ConfirmationOfIncidenceId
										WHERE [A1].[Guide_Serie] = @GuideSerie AND [A1].[Guide_Number] = @GuideNumber 
										AND A2.ClientConfirmsReturn = 1
										)
		
	IF (@ClientConfirmsReturn = 1 )
	BEGIN
	 SET @Incidentsavailable = 0
	END 


    SET NOCOUNT ON;

    BEGIN TRY
        --Verifica que existan registros de la guia
        SELECT @ExistRegister = 
				CASE 
					WHEN EXISTS (
						SELECT 1
						FROM [dbo].[DeliveryOrder] [DDO] WITH (NOLOCK)
						INNER JOIN [dbo].[DeliveryOrderPiece] [DOP] WITH (NOLOCK)
							ON [DDO].[Guide_Number] = [DOP].[GuideNumber]
                            AND [DDO].[Guide_Serie] = [DOP].[GuideSerie]
						WHERE 
							[DDO].[Guide_Serie] = @GuideSerie 
							AND [DDO].[Guide_Number] = @GuideNumber 
							AND (ISNULL([DDO].GuideType,'DOM')='INT'
								OR (ISNULL([DDO].SenderCountryId,'GT')=@IdCountry AND ISNULL([DDO].GuideType,'DOM')='DOM')
								)
					) THEN 1
					ELSE 0
				END;


        SELECT @STATUS = [DO].[StatusOrderId],
               @Sender_Department = [Sender_Department],
               @Receiver_Department = [Receiver_Department],
               @Sender_Town = [SenderIdTownship],
               @Receiver_Town = [ReceiverIdTownship],
               @StatusName = [SO].[OrderDescription],
			   @CustomerName = [CU].[Name]
        FROM [dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
            INNER JOIN [dbo].[StatusOrder] [SO] WITH (NOLOCK)
                ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
			INNER JOIN [dbo].[Customer] [CU] WITH(NOLOCK)
				ON [DO].[IdCustomer] = [CU].[IdCustomer]
        WHERE [DO].[Guide_Serie] = @GuideSerie AND [DO].[Guide_Number] = @GuideNumber 
			--AND ([DO].[SenderCountryId] = @IdCountry OR ([DO].[SenderCountryId] IS NULL AND @IdCountry ='GT'))
        DECLARE @isreturnt BIT =
                (
                    SELECT [IsLastMileReturn]
                    FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
                    WHERE [DO].[Guide_Serie] = @GuideSerie AND [DO].[Guide_Number] = @GuideNumber 
                );

        IF (@ExistRegister = 1)
        BEGIN

            IF (@STATUS IN ( @Entregado, @Anulado, @EntregadoEnExpressCenter, @Terminal ))
            BEGIN

                SELECT [Result] = 1,
                       @StatusName 'Status',
					   @CustomerName 'CustomerName',
                       CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus'; /* Estados no validos*/
            END;
            ELSE IF (@isreturnt = 1)
            BEGIN

                SELECT [Result] = 6,
                       @StatusName 'Status',
					   @CustomerName 'CustomerName',
                       CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus'; /* Estados Devuelto*/

            END;
            ELSE
            BEGIN

                 SELECT CASE WHEN @Incidentsavailable > 0  THEN  7 
				         ELSE
				         0 END [Result],
                       @StatusName 'Status',
					   @CustomerName 'CustomerName',
                       CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus';
            END;

        END;
        ELSE
        BEGIN
            --Verifica que existan registros de la guia en otro pais
            SELECT @ExistRegisterInAnotherCountry = 
				    CASE 
					    WHEN EXISTS (
						    SELECT 1
						    FROM [dbo].[DeliveryOrder] [DDO] WITH (NOLOCK)
						    WHERE 
							    [DDO].[Guide_Serie] = @GuideSerie 
							    AND [DDO].[Guide_Number] = @GuideNumber 
							    AND ISNULL([DDO].SenderCountryId,'GT') <> @IdCountry AND ISNULL([DDO].GuideType,'DOM')='DOM'
					    ) THEN 1
					    ELSE 0
				    END;
            IF(@ExistRegisterInAnotherCountry = 1)
			BEGIN
				SELECT [Result] = 8,
                   @StatusName 'Status',
                   @CustomerName 'CustomerName',
                   CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus'; /* La guia pertenece a otro pais*/
			END
            ELSE
            BEGIN
            SELECT [Result] = 3,
                   @StatusName 'Status',
                   @CustomerName 'CustomerName',
                   CONVERT(NVARCHAR, @DateStatus, 103) 'DateStatus'; /* Guía no existe*/
            END
        END;



    END TRY
    BEGIN CATCH

        SELECT [Result] = 4, /*Error de transacción*/
               ERROR_MESSAGE() AS 'Description';
    END CATCH;
END;