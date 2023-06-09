

-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description, Detalle de manifiesto  global DE Entrega de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestDeliveryGlobalDetailTSE]  
	
AS
BEGIN

	DECLARE @TempPieces TABLE (
		RowNum INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		Detail NVARCHAR(2500)
	);

	DECLARE @TempMinBlankPiece TABLE (
		RowNum INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT
	);

	;WITH PiezasEnProcesoTSE AS
	(
		SELECT
			ROW_NUMBER() OVER (PARTITION BY [TRPD].[GuideNumber] ORDER BY [TRPD].[GuideNumber]) [RowNum]
			,[TRPD].[GuideSerie]
			,[TRPD].[GuideNumber]
			,[DOP].[Detail]
			,(
				SELECT 
					COUNT([DOPaux].[Detail]) 
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOPaux  WITH(NOLOCK) 
				WHERE
					[DOPaux].[GuideSerie] = [DOP].[GuideSerie]
					AND
					[DOPaux].[GuideNumber] = [DOP].[GuideNumber]
			) [MaxValue]
			
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP  WITH(NOLOCK) 
			INNER JOIN
				[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TRPD  WITH(NOLOCK) 
				ON
					[DOP].[GuideSerie] = [TRPD].[GuideSerie]
					AND
					[DOP].[GuideNumber] = [TRPD].[GuideNumber]
					AND
					[TRPD].[RowStatus] = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TRPH  WITH(NOLOCK) 
				ON
					[TRPD].[TSERoutePreparationHeaderID] = [TRPH].[IDTSERoutePreparationHeader]
		WHERE
		
			--[TRPH].[RowStatus] = 1
		--AND
			[TRPD].[RowStatus] = 1
		AND
		TRPH.HasLastDeliveryProccess  =1 
		UNION ALL
		SELECT
			([RowNum] + 1) [RowNum],
			[GuideSerie],
			[GuideNumber],
			CAST('' AS VARCHAR(2500)) [Detail],
			[MaxValue]
		FROM
			[PiezasEnProcesoTSE]
		WHERE
			[RowNum] < 40
			AND
			([RowNum] + 1) > [MaxValue]
	)
	INSERT INTO @TempPieces
	(
		[RowNum],
		[GuideSerie],
		[GuideNumber],
		[Detail]
	)
	SELECT 
		[PiezasEnProcesoTSE].[RowNum],
		[PiezasEnProcesoTSE].[GuideSerie],
		[PiezasEnProcesoTSE].[GuideNumber],
		[PiezasEnProcesoTSE].[Detail]
	FROM 
		PiezasEnProcesoTSE
		
	INSERT INTO @TempMinBlankPiece
	(
	    [RowNum],
	    [GuideSerie],
	    [GuideNumber]
	)
	SELECT 
		MIN([TP].[RowNum])
		,[TP].[GuideSerie]
		,[TP].[GuideNumber]
	FROM
		@TempPieces TP
	WHERE
		ISNULL([TP].[Detail], '') = ''
	GROUP BY
		[TP].[GuideSerie],
		[TP].[GuideNumber]

	--UPDATE
	--	TP
	--SET
	--	TP.[Detail] = 'SOBRE'
	--FROM
	--	@TempPieces TP
	--	INNER JOIN
	--		@TempMinBlankPiece TMBP
	--		ON
	--			[TP].[RowNum] = [TMBP].[RowNum]
	--			AND
	--			[TP].[GuideSerie] = [TMBP].[GuideSerie]
	--			AND
	--			[TP].[GuideNumber] = [TMBP].[GuideNumber]

	SELECT 
		DISTINCT 
		    TRPD.GuideSerie + Convert(NVARCHAR(50),TRPD.GuideNumber) Guide,
			TRPD.GuideNumber,
			TRPD.IDTSERoutePreparationDetail,
			[DO].[Receiver_FirstName] [VoteCenter],
			[DO].[Receiver_Address] [Adress],
			Upper([DO].[Receiver_Alternant_FullName]) [Coordinador],
			SR.First_Name +' '+ SR.Last_Name [Curierman],
			CV.UnitNumber+'-'+CV.Plate Plate,
			Upper(CRC.ClusterName) ClusterName,
			FORMAT(GETDATE(),'dd-MM-yyyyy hh:mm:ss') [DateExec],
		    CR.CodeRoute ,
			(
				SELECT
					SUM
					(
						CASE
							WHEN LTRIM(RTRIM([TP].[Detail])) <> '' THEN 1
							ELSE 0
						END
					)
				FROM
					@TempPieces TP
				WHERE
					TP.GuideSerie = TRPD.GuideSerie 
					AND 
					TP.GuideNumber = TRPD.GuideNumber
				GROUP BY
					[TP].[GuideSerie],
					[TP].[GuideNumber]
			) TotalPieces,
			(
				SELECT 
					STUFF
					(
						( 
							SELECT ',' + TP.Detail 
							FROM @TempPieces TP
							WHERE  TP.GuideSerie = TRPD.GuideSerie AND 
							TP.GuideNumber = TRPD.GuideNumber
							FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
					) 
			) Pieces
	FROM
		[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TRPD  WITH(NOLOCK) 
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			ON
				[DO].[Guide_Serie] = [TRPD].[GuideSerie]
				AND
				[DO].[Guide_Number] = [TRPD].[GuideNumber]
		INNER JOIN
			[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TRPH  WITH(NOLOCK) 
			ON 
				TRPH.IdTSERoutePreparationHeader = TRPD.TSERoutePreparationHeaderID
				---Agregar campos de cabecera
				Inner Join 
		 [dbo].[SenderReceiver] SR WITH (NOLOCK)
		 ON TRPH.SenderReceiverId = SR.ID
		 Inner Join 
		 [dbo].[SenderReceiver] SR1 WITH (NOLOCK)
		 ON TRPH.IdRouteSupervisor = SR1.ID
		 Inner Join 
		 [dbo].[SenderReceiver] SR2 WITH (NOLOCK)
		 ON  TRPH.IdRouteLeader  = SR2.ID
		 Inner Join
		 [dbo].[CatRouteCluster] CRC WITH (NOLOCK)
		 ON   TRPH.IdCatRouteCluster = CRC.IdCatRouteCluster
		 Inner Join 
		 [dbo].[CatVehicle] CV  WITH (NOLOCK)
		 ON TRPH.IdCatVehicle = CV.IdVehicle 
		 Inner Join [dbo].[CatRoute] CR
		 On TRPH.IdCatRoute = CR.IdRoute
	WHERE 
		--[DO].[Pieces_Dry] > 1
		--AND
		[TRPD].[RowStatus] = 1
		AND
		TRPH.HasLastDeliveryProccess  =1 
	ORDER BY
		[TRPD].[GuideNumber] ASC

END;