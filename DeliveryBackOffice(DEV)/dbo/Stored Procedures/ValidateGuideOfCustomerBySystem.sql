


-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-17>
-- Description:	< Verificar datos de la guía a ser procesada para flujo de entrega que requiera multiples imagenes como comprobante de entrega >
-- =============================================

CREATE PROCEDURE [dbo].[ValidateGuideOfCustomerBySystem]
	@GuideSerie NVARCHAR(2) = 'FD',
	@GuideNumber INT,
	@GuidePiece INT = 1,
	@CourierToken NVARCHAR(50) = '' -- En caso se quiera volver a validar sesión de Courier
AS 
BEGIN

	-- Varaible del identificador del systema
	DECLARE @ImageRegisterCourierAppId INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WHERE CS.SysNameSystem = 'App-Evidencias' COLLATE Latin1_General_CI_AI);
	
	-- Variables de respuesta
	DECLARE @jsonResult NVARCHAR(MAX);
	-- Manejo de datos de retorno
	DECLARE @GuidesToValidate AS TABLE(
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		IsValid BIT,
		GuideTotalPieces INT,
		GuideMessage NVARCHAR(200),
		GuideItemType NVARCHAR(50),
		GuideReceiver NVARCHAR(200)
	);
	DECLARE @ImagesOfGuide AS TABLE(
		ImageName NVARCHAR(50),
		ImageDescription NVARCHAR(200),
		IsRequired BIT
	);

	-- Manejo de datos de guía
	DECLARE @GuideData AS TABLE (
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		GuidePiece INT,
		GuideSender INT,
		GuideCustomer INT,
		GuideDryPieces INT,
		GuideColdPieces INT,
		GuideReceiver NVARCHAR(200),
		GuideStatus TINYINT
	);

	BEGIN TRY

		-- Ingresar datos necesarios para no usar DeliveryOrder
		INSERT INTO
			@GuideData
			(GuideSerie, GuideNumber, GuidePiece, GuideSender, GuideCustomer, GuideDryPieces, GuideColdPieces, GuideReceiver, GuideStatus)
		SELECT
			@GuideSerie
			,@GuideNumber
			,@GuidePiece
			,DO.Sender_ID
			,DO.IdCustomer
			,DO.Pieces_Dry
			,DO.Pieces_Cold
			,LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName, ' ', DO.Receiver_LastName))) 'ReceiverName'
			,DO.StatusOrderId
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		WHERE
			DO.Guide_Serie = @GuideSerie
			AND
			DO.Guide_Number = @GuideNumber

		-- Validar guía
		INSERT INTO
			@GuidesToValidate
			(GuideSerie, GuideNumber, IsValid, GuideMessage, GuideTotalPieces, GuideItemType, GuideReceiver)
		SELECT
			DISTINCT
				@GuideSerie
				,@GuideNumber
				,(
					CASE
						WHEN CBS.IdCustomerByModuleBySystem IS NULL THEN 0
						WHEN DOP.GuidePiece IS NULL THEN 0
						WHEN ABC.AbcId IS NULL THEN 0
						WHEN DO.GuideStatus != 4 THEN 0
						ELSE 1
					END
				)
				, (
					CASE
						WHEN CBS.IdCustomerByModuleBySystem IS NULL THEN CONCAT('Guía ',@GuideSerie,@GuideNumber,' no corresponde a cliente permitido en este sistema.')
						WHEN DOP.GuidePiece IS NULL THEN CONCAT('Pieza ',@GuidePiece,' inexistente para guía ',@GuideSerie,@GuideNumber,'.')
						WHEN ABC.AbcId IS NULL THEN CONCAT('Tipo de paquete inexistente o no valido.',@GuideSerie,@GuideNumber,'.')
						WHEN DO.GuideStatus != 4 THEN CONCAT('Guía ',@GuideSerie,@GuideNumber,' no ha sido despachada a ruta en este día.')
						ELSE NULL
					END
				)
				,(
					CASE
						WHEN CBS.IdCustomerByModuleBySystem IS NULL THEN NULL
						WHEN DOP.GuidePiece IS NULL THEN NULL
						WHEN ABC.AbcId IS NULL THEN NULL
						WHEN DO.GuideStatus != 4 THEN NULL
						ELSE (ISNULL(DO.GuideDryPieces, 0) + ISNULL(DO.GuideColdPieces, 0))
					END
				) 
				,(
					CASE
						WHEN CBS.IdCustomerByModuleBySystem IS NULL THEN NULL
						WHEN DOP.GuidePiece IS NULL THEN NULL
						WHEN ABC.AbcId IS NULL THEN NULL
						WHEN DO.GuideStatus != 4 THEN NULL
						ELSE CA.ArtName
					END
				)
				,(
					CASE
						WHEN CBS.IdCustomerByModuleBySystem IS NULL THEN NULL
						WHEN DOP.GuidePiece IS NULL THEN NULL
						WHEN ABC.AbcId IS NULL THEN NULL
						WHEN DO.GuideStatus != 4 THEN NULL
						ELSE DO.GuideReceiver
					END
				)
		FROM
			@GuideData DO
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
				ON
					DO.GuideSender = VPC.CodeOfReference
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					ISNULL(DO.GuideCustomer, VPC.CustomerID) = Cu.IdCustomer
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
				ON
					DO.GuideSerie = DOP.GuideSerie
					AND
					DO.GuideNumber = DOP.GuideNumber
					AND
					DOP.NoPiece = @GuidePiece
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CustomerConfigurationSystem] CBS WITH(NOLOCK)
				ON
					Cu.IdCustomer = CBS.CustomerId
					AND
					CBS.SystemId = @ImageRegisterCourierAppId
					AND
					CBS.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
				ON
					DOP.ParcelCode = ABC.Code
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK)
				ON
					ABC.AbcIdArticle = CA.ArtId
			/*LEFT JOIN
				[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH(NOLOCK)
				ON
					DO.GuideSerie = DSD.Guide_Serie
					AND
					DO.GuideNumber = DSD.Guide_Number
					AND
					CAST(DSD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
					AND
					DSD.RowStatus = 1*/

		INSERT INTO
			@ImagesOfGuide
			(ImageName, ImageDescription, IsRequired)
		SELECT
			DISTINCT
				CTOI.TypeOfImageName,
				CTOI.TypeOfImageDescription,
				TIBA.IsRequired
		FROM
			@GuidesToValidate GTV
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
				ON
					GTV.GuideSerie = DOP.GuideSerie
					AND
					GTV.GuideNumber = DOP.GuideNumber
					AND
					DOP.NoPiece = @GuidePiece
			INNER JOIN
				[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
				ON
					DOP.ParcelCode = ABC.Code
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK)
				ON
					ABC.AbcIdArticle = CA.ArtId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[TypeImageByArticle] TIBA WITH(NOLOCK)
				ON
					CA.ArtId = TIBA.ArticleId
					AND
					TIBA.RowStatus = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatTypeOfImage] CTOI WITH(NOLOCK)
				ON
					TIBA.TypeOfImageId = CTOI.IdTypeOfImage
					AND
					CTOI.RowStatus = 1
		WHERE
			GTV.IsValid = 1 

		SET @jsonResult = (SELECT STUFF(( 
							SELECT  
								',{' + 
									'"IdResult":200' + ',' + 
									'"Guide":"' +  CONCAT(GTV.GuideSerie, GTV.GuideNumber) + '",' +
									'"GuideReceiver":"' +  ISNULL(GTV.GuideReceiver,'') + '",' +
									'"Article":"' +  ISNULL(GTV.GuideItemType,'') + '",' +
									'"IsValid":' + CAST(GTV.IsValid AS NVARCHAR) + ',' +
									'"TotalGuidePieces":' + CAST(ISNULL(GTV.GuideTotalPieces,0) AS NVARCHAR) + ',' +
									'"ImageData":[' + IIF((SELECT TOP 1 1 FROM @ImagesOfGuide) = 1, (
										SELECT STUFF(( 
											SELECT  
												',{' + 
													'"ImageName":"' +  ISNULL(IOG.ImageName,'') + '",' +
													'"ImageDescription":"' + ISNULL(IOG.ImageDescription,'') + '",' +
													'"IsRequired":' + CAST(ISNULL(IOG.IsRequired,0) AS NVARCHAR) +
												+ '}'
												FROM
													@ImagesOfGuide IOG
											FOR XML PATH(''), TYPE
											).value('.', 'varchar(max)'),1,1,''
											) 
									), '') + '],' +
									'"GuideMessage":"' + ISNULL(GTV.GuideMessage,'') + '"' +
								+ '}'

								FROM
									@GuidesToValidate GTV
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) )

		IF(@jsonResult IS NULL) 
		BEGIN

			SET @jsonResult = (SELECT STUFF(( 
								SELECT  
									',{' + 
										'"IdResult":400' + ',' + 
										'"Guide":"' +  CONCAT(@GuideSerie, @GuideNumber) + '",' +
										'"Article":"",' +
										'"IsValid":0,' +
										'"TotalGuidePieces":0,' +
										'"ImageData":[],' +
										'"GuideMessage":"' + CONCAT(@GuideSerie, @GuideNumber,'-',@GuidePiece) + ', guia o pieza inexistente."' +
									+ '}'
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
								) )

		END

		SELECT @jsonResult 'JsonResult'

	END TRY
	BEGIN CATCH
	
		SET @jsonResult = (SELECT STUFF(( 
							SELECT  
								',{' + 
									'"IdResult":500' + ',' + 
									'"Guide":"' +  CONCAT(@GuideSerie, @GuideNumber) + '",' +
									'"Article":"",' +
									'"IsValid":0,' +
									'"TotalGuidePieces":0,' +
									'"ImageData":[],' +
									'"GuideMessage":"' + ERROR_MESSAGE() + '"' +
								+ '}'
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) )

		SELECT @jsonResult 'JsonError'
	END CATCH
END;


SELECT
	*
FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS
WHERE
	DOBS.ID = 32631