
-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-04-10>
-- Description:	<Obtener información de guías de concecionarios>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-08-20>
-- Description:	<Se agrega el filtro por pais>
-- =============================================
CREATE PROCEDURE [dbo].[spRS_GetConcessionaireGuides]

	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,																																																																															
	@FilteredGuide NVARCHAR(MAX) = NULL,
	@IdCountry NVARCHAR(5) = 'GT'

AS
BEGIN

	DECLARE @FranchiseVPCType INT = (
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM 
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Concesionario' AND IdCountry = @IdCountry
	)

	DECLARE @TempGuideSplit TABLE (
		GuideSerie NVARCHAR(2),
		GuideNumber INT
	);

	IF(@FilteredGuide IS NOT NULL)
	BEGIN

	    INSERT INTO @TempGuideSplit
		(
			[GuideSerie],
			[GuideNumber]
		)
		SELECT 
			SUBSTRING(Item, 1, 2) ItemSerie,
			SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber
		FROM
			[DeliveryBackOffice].[dbo].[SplitUnlimited](@FilteredGuide,',') SU

	END
	

	-- Manejo de fechas
	IF(@EndDate IS NULL)
	BEGIN

		SET @EndDate = DATEADD(DAY,-1,DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))

	END
	ELSE 
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@EndDate AS DATE) AS DATETIME)))

	END

	IF(@StartDate IS NULL)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-0,@EndDate) AS DATE) AS DATETIME)

	END
	ELSE
	BEGIN

		SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)

	END

	IF(NOT EXISTS ( SELECT TOP 1 1 FROM @TempGuideSplit ))
	BEGIN
	    
		SELECT 
			DISTINCT
				CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [Guide]
				,(
					CASE
						WHEN [DO].[IsCollect] = 1 THEN 'Si'
						ELSE 'No'
					END
				) [Collect]
				,[SO].[OrderDescription] [LastStatus]
				,FORMAT([DODlast].[LastStatusDate], 'dd/MM/yyyy hh:mm:ss') [LastStatusDate]
				,[DO].[PriceShippment] [GuidePrice]
				,[DO].[Collect_OnDelivery] [COD]
				,(
					CASE 
						WHEN LTRIM(RTRIM(ISNULL([InH].[inv_certificationFEL], ''))) = '' THEN NULL
						ELSE [InH].[inv_certificationFEL]
					END
				) [CertificationFEL]
				,(
					CASE 
						WHEN LTRIM(RTRIM(ISNULL([InH].[inv_certificationFEL], ''))) = '' THEN NULL
						ELSE FORMAT([InH].[inv_dateFEL], 'dd/MM/yyyy hh:mm:ss')
					END
				) [DateCertificationFEL]
				,LTRIM(RTRIM(CONCAT([DO].[Sender_FirstName], ' ', [DO].[Sender_LastName]))) [Origin]
				,LTRIM(RTRIM(CONCAT([DO].[Receiver_FirstName], ' ', [DO].[Receiver_LastName]))) [Destiny]
				,[VPC].[DescriptionOfClient] [Franchise]
				,CASE WHEN ISNULL(DO.SenderCountryId,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			INNER JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
				ON
					[DO].[Sender_ID] = [VPC].[CodeOfReference]
			OUTER APPLY
			(
				SELECT 
					TOP (1) 
						[DOD].[StatusOrderId] [LastStatusId]
						,[DOD].[DateCreated] [LastStatusDate]
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD  WITH(NOLOCK) 
				WHERE
					[DO].[Guide_Serie] = [DOD].[Guide_Serie]
					AND
					[DO].[Guide_Number] = [DOD].[Guide_Number]
					AND
					[DOD].[RowStatus] = 1
				ORDER BY
					[DOD].[DateCreated] DESC
			) DODlast
			INNER JOIN
				[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
				ON
					[SO].[StatusOrderId] = [DODlast].[LastStatusId]
			OUTER APPLY
			(
				SELECT 
					TOP (1) 
						[InH].[inv_certificationFEL]
						,[InH].[inv_dateFEL]
				FROM 
					[DeliveryBackOffice].[dbo].[invoiceDetail] InD  WITH(NOLOCK) 
					LEFT JOIN
						[DeliveryBackOffice].[dbo].[invoiceHeader] InH  WITH(NOLOCK) 
						ON
							[InD].[dti_fk_header] = [InH].[inv_pk_id]
							AND
							[InH].[inv_invoiceOfCreditNote] IS NULL
							AND
							[InH].[inv_creditNote] IS NULL
				WHERE
					[DO].[Guide_Serie] = [InD].[dti_fk_orderSerie]
					AND
					[DO].[Guide_Number] = [InD].[dti_fk_orderNumber]
				ORDER BY
					ISNULL([InH].[inv_certificationFEL],'') DESC,
					[InH].[inv_date] DESC
			) INH
		WHERE
			[DO].[DateCreated] BETWEEN @StartDate AND @EndDate
			AND ISNULL(DO.SenderCountryId,'GT') = @IdCountry
            AND [VPC].[IdKindOfVPClient] = @FranchiseVPCType
		
	END
	ELSE
	BEGIN
	    
		SELECT 
			DISTINCT
				CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [Guide]
				,(
					CASE
						WHEN [DO].[IsCollect] = 1 THEN 'Si'
						ELSE 'No'
					END
				) [Collect]
				,[SO].[OrderDescription] [LastStatus]
				,FORMAT([DODlast].[LastStatusDate], 'dd/MM/yyyy hh:mm:ss') [LastStatusDate]
				,[DO].[PriceShippment] [GuidePrice]
				,[DO].[Collect_OnDelivery] [COD]
				,(
					CASE 
						WHEN LTRIM(RTRIM(ISNULL([InH].[inv_certificationFEL], ''))) = '' THEN NULL
						ELSE [InH].[inv_certificationFEL]
					END
				) [CertificationFEL]
				,(
					CASE 
						WHEN LTRIM(RTRIM(ISNULL([InH].[inv_certificationFEL], ''))) = '' THEN NULL
						ELSE FORMAT([InH].[inv_dateFEL], 'dd/MM/yyyy hh:mm:ss')
					END
				) [DateCertificationFEL]
				,LTRIM(RTRIM(CONCAT([DO].[Sender_FirstName], ' ', [DO].[Sender_LastName]))) [Origin]
				,LTRIM(RTRIM(CONCAT([DO].[Receiver_FirstName], ' ', [DO].[Receiver_LastName]))) [Destiny]
				,[VPC].[DescriptionOfClient] [Franchise]
				,CASE WHEN ISNULL(DO.SenderCountryId,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			INNER JOIN
				@TempGuideSplit TGS 
				ON
					[DO].[Guide_Serie] = [TGS].[GuideSerie]
					AND
					[DO].[Guide_Number] = [TGS].[GuideNumber]
			INNER JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
				ON
					[DO].[Sender_ID] = [VPC].[CodeOfReference]
			OUTER APPLY
			(
				SELECT 
					TOP (1) 
						[DOD].[StatusOrderId] [LastStatusId]
						,[DOD].[DateCreated] [LastStatusDate]
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD  WITH(NOLOCK) 
				WHERE
					[DO].[Guide_Serie] = [DOD].[Guide_Serie]
					AND
					[DO].[Guide_Number] = [DOD].[Guide_Number]
					AND
					[DOD].[RowStatus] = 1
				ORDER BY
					[DOD].[DateCreated] DESC
			) DODlast
			INNER JOIN
				[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
				ON
					[SO].[StatusOrderId] = [DODlast].[LastStatusId]
			OUTER APPLY
			(
				SELECT 
					TOP (1) 
						[InH].[inv_certificationFEL]
						,[InH].[inv_dateFEL]
				FROM 
					[DeliveryBackOffice].[dbo].[invoiceDetail] InD  WITH(NOLOCK) 
					LEFT JOIN
						[DeliveryBackOffice].[dbo].[invoiceHeader] InH  WITH(NOLOCK) 
						ON
							[InD].[dti_fk_header] = [InH].[inv_pk_id]
							AND
							[InH].[inv_invoiceOfCreditNote] IS NULL
							AND
							[InH].[inv_creditNote] IS NULL
				WHERE
					[DO].[Guide_Serie] = [InD].[dti_fk_orderSerie]
					AND
					[DO].[Guide_Number] = [InD].[dti_fk_orderNumber]
				ORDER BY
					ISNULL([InH].[inv_certificationFEL],'') DESC,
					[InH].[inv_date] DESC
			) INH
		WHERE
			[DO].[DateCreated] BETWEEN @StartDate AND @EndDate
			AND ISNULL(DO.SenderCountryId,'GT') = @IdCountry
            AND [VPC].[IdKindOfVPClient] = @FranchiseVPCType
		
	END

END