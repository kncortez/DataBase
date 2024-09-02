-- =============================================
-- Author:		<Author, Michael Espinoza>
-- Create date: <Create Date,3-12-2021>
-- Description:	<Description, it confirms if a guide number meets all the requirements of a transfer, if so it returns all the necessary data >
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-07-04>
-- Description: <Se agrega filtro por pais para filtrar guias>
-- =============================================
CREATE PROCEDURE [dbo].[spws_check_transfer_guide]
	
	@Guide VARCHAR(MAX), 
	@Token VARCHAR(100) = '',
    @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @GuideInRoute INT = (
		SELECT 
			TOP (1) 
				[SO].[StatusOrderId]
		FROM 
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			SO.[OrderDescription] = 'En ruta'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @GuideInReturnRoute INT = (
		SELECT 
			TOP (1) 
				[SO].[StatusOrderId]
		FROM 
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			SO.[OrderDescription] = 'En ruta para devolución'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @IncidenceInRoute INT = (
		SELECT 
			TOP (1) 
				[SO].[StatusOrderId] 
		FROM 
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			SO.[OrderDescription] = 'Incidencia en ruta'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @FailedDeliveryAttempt INT = (
		SELECT 
			TOP (1) 
				[SO].[StatusOrderId]
		FROM 
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			SO.[OrderDescription] = 'Intento de entrega fallida'  COLLATE Latin1_General_CI_AI 
	)

	DECLARE @ValidatedIncident INT = (
		SELECT 
			TOP (1) 
				[SO].[StatusOrderId]
		FROM 
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE SO.StatusOrderId = 50 --Incidencia validada
	)

	DECLARE @Series NVARCHAR(50) = SUBSTRING(@Guide, 1, 2);
	DECLARE @Guide_number NVARCHAR(50) = SUBSTRING(@Guide, 3, LEN(@Guide));
	DECLARE @jsonResult NVARCHAR(MAX) = '';

	DECLARE @Status INT =  (SELECT StatusOrderId 
                              FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) 
                             WHERE Guide_Serie = @Series 
                               AND Guide_Number = @Guide_number
                               AND ISNULL(ReceiverCountryId,'GT') = @IdCountry
                               )
	DECLARE @IdCourier INT = (
	SELECT TOP 1 ID_Courier FROM DeliveryBackOffice.dbo.DeliveryAttempt WITH(NOLOCK)
	WHERE Guide_Serie = @Series AND Guide_Number = @Guide_number ORDER BY Date_Created DESC
	);
	
	IF(ISNULL(@IdCourier,0) = 0)
	BEGIN
		SET @IdCourier = (
			SELECT TOP 1 stp.IdCourier  
			FROM dbo.SettlementByPickup stp WITH (NOLOCK)
				LEFT JOIN dbo.SettlementByPickupDetail std WITH (NOLOCK) ON std.SettlementByPickupId = stp.Id
				LEFT JOIN dbo.DeliveryOrderPiece dpc WITH (NOLOCK) ON dpc.GuideSerie = std.GuideSerie AND dpc.GuideNumber = std.GuideNumber
				LEFT JOIN dbo.PieceByService pbs WITH (NOLOCK) ON pbs.GuidePieceId = dpc.GuidePiece
				LEFT JOIN dbo.ServiceManagement smg WITH (NOLOCK) ON smg.IdServiceManagement = pbs.ServiceManagmentId
				LEFT JOIN dbo.RouteAssigment ras WITH (NOLOCK) ON ras.IdRouteAssigment = smg.IdDlRouteAssigment
			WHERE dpc.GuideNumber = @Guide_number AND CONVERT(DATE, stp.DateCreated) = CONVERT(DATE, GETDATE())
			and smG.SubTypeServiceManagmentId = 3
		)
	END




	IF(@Status IN(@GuideInRoute,@GuideInReturnRoute,@IncidenceInRoute,@FailedDeliveryAttempt,@ValidatedIncident) And @Status NOT IN (
	
											SELECT
												SO.[StatusOrderId]
											FROM
											[dbo].[StatusOrder] SO  WITH(NOLOCK)
											WHERE
											[CatCheckpointTypeId] = 3 ))
	BEGIN

	BEGIN TRY

	SET @jsonResult = ISNULL((
		SELECT STUFF(
			(
				SELECT DISTINCT ',{ "IdResult": 200 ,' +
									'"Message": "Guía fue procesada con éxito." ' +
									',"GuideData":{"'+
												'Guide":"'+@Guide+'",'+ 
												'"SenderName": "'+dbo.fnt_String_Escape([dbo].[fn_replace_special_characters](ISNULL(dor.Sender_FirstName,'')),'json')+'",'+
												'"SenderAddress":"'+ dbo.fnt_String_Escape(REPLACE(ISNULL(dor.Sender_Address,''),'"',''),'json') + '",'+
												'"SenderProvince":"'+dor.Sender_Department+'",'+
												'"SenderTownship":"'+dor.Sender_Town+'",'+
												'"ReceiverName":"'+dbo.fnt_String_Escape([dbo].[fn_replace_special_characters](ISNULL(dor.Receiver_FirstName,'')),'json')+'",'+
												'"ReceiverAddress":"'+dbo.fnt_String_Escape(REPLACE(ISNULL(dor.Receiver_Address,''),'"',''),'json')+'",'+
												'"ReceiverProvince":"'+dor.Receiver_Department+'",'+
												'"ReceiverTownship":"'+dor.Receiver_Town+'",'+
												'"ServiceType":"'+ CASE WHEN dor.TypeService='NDD' OR dor.TypeService='TDA' THEN 'NEXT DAY' ELSE 'SAME DAY' END +'",'+
												'"PiecesDry":'+ CONVERT(VARCHAR,ISNULL( dor.Pieces_Dry, '') ) +','+
												'"PiecesCold":'+ CONVERT(VARCHAR,ISNULL( dor.Pieces_Cold, '') )  +','+
												'"ShipmentPrice":'+CONVERT(VARCHAR,ISNULL( dor.PriceShippment, '') ) +','+
												'"IsLastMileReturn":'+CONVERT(VARCHAR, ISNULL( (CASE WHEN dor.IsLastMileReturn = 1 THEN 1 ELSE 0 END), 0) ) +','+
												'"COD":'+CONVERT(VARCHAR,ISNULL( dor.Collect_OnDelivery, '') ) +''+
											'},'+
									'"CourierData":{'+
												'"CourierId":'+CONVERT(VARCHAR,ISNULL(sr.ID,''))+','+
												'"CourierFirstName":"'+dbo.fnt_String_Escape([dbo].[fn_replace_special_characters](ISNULL(sr.First_Name,'')),'json')+'",'+
												'"CourierLastName":"'+dbo.fnt_String_Escape([dbo].[fn_replace_special_characters](ISNULL(sr.Last_Name,'')),'json')+'",'+
												'"CourierDPI":"'+sr.CUI+'"'+
											'}'
								+'}'
				FROM DeliveryBackOffice.dbo.DeliveryOrder dor WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = @IdCourier
				WHERE
				dor.Guide_Number = @Guide_number AND dor.Guide_Serie = @Series
                  AND ISNULL(dor.ReceiverCountryId,'GT') = @IdCountry
				
				FOR XML PATH('') 
			)
			, 1, 1, '' )
		),'')
    
	IF ( LEN(@jsonResult) = 0 )

    BEGIN

        -- ERROR messages for internal purposes ---------------

    --    SELECT 'Error' AS message,
				--'FALSE'	blnResult,
				--CAST(-1 AS VARCHAR(5)) IdResult,
				--CAST(500 AS VARCHAR(5)) StatusResult

        -------------------------------------------------------
        SET @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult": 400,"Message":"No se encontraron registros."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'VARCHAR(max)'),1,1,''
									  ) 
							)

    END
	
	END TRY

	BEGIN CATCH

				DECLARE @errorMessage NVARCHAR(100) = (SELECT CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage);

        -- ERROR messages for internal purposes ---------------

        DECLARE @xmltmp xml = (
        SELECT 'Error' ,
				'FALSE'	,
				CAST(-1 AS VARCHAR(5)) ,
				CAST(500 AS VARCHAR(5)) ,
				CAST(ERROR_NUMBER() AS VARCHAR) ,
				CAST(ERROR_SEVERITY() AS VARCHAR) ,
				CAST(ERROR_STATE() AS VARCHAR) ,
				CAST(ERROR_PROCEDURE() AS VARCHAR) ,
				CAST(ERROR_LINE() AS VARCHAR) ,
				CAST(ERROR_MESSAGE() AS VARCHAR(MAX))
        FOR XML PATH(''), TYPE
        )
        PRINT CONVERT(NVARCHAR(MAX), @xmltmp)
        -------------------------------------------------------
								-- retornar mensaje de error
							SET @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult": 500,' 
								+ '"Message":"' + @errorMessage + '"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'VARCHAR(max)'),1,1,''
									  ) 
							)

	END CATCH

	END

	ELSE
	BEGIN

	IF(@Status IS NULL)
	BEGIN
	SET @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult": 400,' 
								+ '"Message":"No se encontraron registros."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'VARCHAR(max)'),1,1,''
									  ) 
							)
	END

	ELSE
	BEGIN
	SET @jsonResult = (
								SELECT STUFF(( 
								SELECT ',{"IdResult": 403,' 
								+ '"Message":"Guía tiene un estado que no permite el traslado asegúrese que la guía fue esta asignada a una ruta."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'VARCHAR(max)'),1,1,''
									  ) 
							)
	END
	

	END

	SELECT ('[' + @jsonResult +  ']') jsonResult

END