-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-03-31>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spRS_GetCreditNotes]

	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@FilteredGuide NVARCHAR(MAX) = NULL,
	@idCountrySender NVARCHAR(2) = 'GT'

AS
BEGIN

	DECLARE @ExpressCenterVPCType INT = (
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM 
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center'
		AND
			ISNULL([KOVPC].IdCountry , 'GT') = @idCountrySender
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
				ISNULL([CS].[SysNameSystem], 'Hermes Integrations') [System]
				,COALESCE([VPC].[DescriptionOfClient], [VPCsec].[DescriptionOfClient], 'N/A') [StoreName]
				,LTRIM(RTRIM(CONCAT([DO].[Sender_FirstName],' ', [DO].[Sender_LastName]))) [Sender]
				,CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [Guide]
				,[DO].[DateCreated]
				,[InHinvoice].[inv_certificationFEL] [InvoiceFEL]
				,[InHcreditnote].[inv_certificationFEL] [CreditnoteFEL]
				,[InHcreditnote].[inv_date] [CreditnoteDate]
				,[InHinvoice].[inv_amount] [InvoiceAmount]
				,COALESCE([LGNLBT].[SSN_Username], [InHcreditnote].[inv_tokenRegister]) [CreditnoteToken]
		FROM
			[DeliveryBackOffice].[dbo].[invoiceHeader] InHcreditnote  WITH(NOLOCK) 
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[invoiceHeader] InHinvoice  WITH(NOLOCK) 
				ON
					[InHcreditnote].[inv_invoiceOfCreditNote] = [InHinvoice].[inv_pk_id]
			INNER JOIN
				[DeliveryBackOffice].[dbo].[invoiceDetail] InD  WITH(NOLOCK) 
				ON
					[InHcreditnote].[inv_pk_id] = [InD].[dti_fk_header]
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				ON
					[InD].[dti_fk_orderSerie] = [DO].[Guide_Serie]
					AND
					[InD].[dti_fk_orderNumber] = [DO].[Guide_Number]
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
				ON
					[DO].[CatSystemId] = [CS].[SysIdSystem]
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
				ON
					[VPC].[CodeOfReference] = [DO].[Sender_ID]
					AND
					[VPC].[IdKindOfVPClient] = @ExpressCenterVPCType
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPCsec  WITH(NOLOCK) 
				ON
					[VPCsec].[CodeOfReference] = [DO].[OriginSenderId]
					AND
					[VPCsec].[IdKindOfVPClient] = @ExpressCenterVPCType
			-- Token de hermes desktop
			LEFT JOIN
				[DenariusUser_Dev].[dbo].[LGN_LogByToken] LGNLBT  WITH(NOLOCK) 
				ON
					[InHcreditnote].[inv_tokenRegister] COLLATE DATABASE_DEFAULT = [LGNLBT].[SSN_IdToken] COLLATE DATABASE_DEFAULT
		WHERE
			[InHcreditnote].[inv_type] = 2
			AND
			[InHcreditnote].[inv_date] BETWEEN @StartDate AND @EndDate
			AND 
			ISNULL(InHcreditnote.IdCountry,'GT') = @idCountrySender
		
	END
	ELSE
	BEGIN
	    
		SELECT 
			DISTINCT
				ISNULL([CS].[SysNameSystem], 'Hermes Integrations') [System]
				,COALESCE([VPC].[DescriptionOfClient], [VPCsec].[DescriptionOfClient], 'N/A') [StoreName]
				,LTRIM(RTRIM(CONCAT([DO].[Sender_FirstName],' ', [DO].[Sender_LastName]))) [Sender]
				,CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [Guide]
				,[DO].[DateCreated]
				,[InHinvoice].[inv_certificationFEL] [InvoiceFEL]
				,[InHcreditnote].[inv_certificationFEL] [CreditnoteFEL]
				,[InHcreditnote].[inv_date] [CreditnoteDate]
				,[InHinvoice].[inv_amount] [InvoiceAmount]
				,COALESCE([LGNLBT].[SSN_Username], [InHcreditnote].[inv_tokenRegister]) [CreditnoteToken]
		FROM
			[DeliveryBackOffice].[dbo].[invoiceHeader] InHcreditnote  WITH(NOLOCK) 
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[invoiceHeader] InHinvoice  WITH(NOLOCK) 
				ON
					[InHcreditnote].[inv_invoiceOfCreditNote] = [InHinvoice].[inv_pk_id]
			INNER JOIN
				[DeliveryBackOffice].[dbo].[invoiceDetail] InD  WITH(NOLOCK) 
				ON
					[InHcreditnote].[inv_pk_id] = [InD].[dti_fk_header]
			INNER JOIN
				@TempGuideSplit TGS 
				ON
					[InD].[dti_fk_orderSerie] = [TGS].[GuideSerie]
					AND
					[InD].[dti_fk_orderNumber] = [TGS].[GuideNumber]
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				ON
					[TGS].[GuideSerie] = [DO].[Guide_Serie]
					AND
					[TGS].[GuideNumber] = [DO].[Guide_Number]
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
				ON
					[DO].[CatSystemId] = [CS].[SysIdSystem]
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
				ON
					[VPC].[CodeOfReference] = [DO].[Sender_ID]
					AND
					[VPC].[IdKindOfVPClient] = @ExpressCenterVPCType
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPCsec  WITH(NOLOCK) 
				ON
					[VPCsec].[CodeOfReference] = [DO].[OriginSenderId]
					AND
					[VPCsec].[IdKindOfVPClient] = @ExpressCenterVPCType
			-- Token de hermes desktop
			LEFT JOIN
				[DenariusUser_Dev].[dbo].[LGN_LogByToken] LGNLBT  WITH(NOLOCK) 
				ON
					[InHcreditnote].[inv_tokenRegister] = [LGNLBT].[SSN_IdToken] 
		WHERE
			[InHcreditnote].[inv_type] = 2
			AND
			[InHcreditnote].[inv_date] BETWEEN @StartDate AND @EndDate
			AND 
			ISNULL(InHcreditnote.IdCountry,'GT') = @idCountrySender
		
	END

END