USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetBillingGuideDetail]    Script Date: 8/11/2021 16:36:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Morales, Oscar>
-- Create date: <2021-11-03>
-- Description:	<Recupera información detallada de la guía a facturar>
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingGuideDetail]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ProductNumber VARCHAR(100) = CONCAT(@GuideSerie,@GuideNumber) 
	DECLARE @TypeService VARCHAR(3)
	DECLARE @Segment VARCHAR(MAX)
	DECLARE @NameArticle VARCHAR(100)
	DECLARE @NameArticleWeight VARCHAR(100)
	DECLARE @NameArticleSecure VARCHAR(100)
	DECLARE @Amount DECIMAL(18,2)
	DECLARE @AmountWeight DECIMAL (18,2)
	DECLARE @AmountSecure DECIMAL (18,2)

	DECLARE @BreakdownOfPayment AS TABLE(
		Description VARCHAR(100) NULL
		,Amount DECIMAL(18,2) NULL
	)

	DECLARE @GuideDetail AS TABLE(
		SAPCode NVARCHAR(50) NULL
		,Name NVARCHAR(100) NULL
		,Description NVARCHAR(100) NULL
		,Price DECIMAL(14,2) NULL
		,Category VARCHAR(50) NULL
		,SendToInvoice BIT NULL
	)

	SET @TypeService = COALESCE((SELECT do.TypeService 
							FROM DeliveryOrder do 
							WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber), 'NDD')

	SET @Segment = (SELECT [dbo].[fn_get_segment] (@GuideSerie,@GuideNumber))
	
	IF @Segment IS NULL
		SET @Segment = 'LOC'
	
	IF @TypeService = 'SDD'
	BEGIN
		SET @NameArticleWeight = 'SAME DAY EXCEDENTE DE PESO'
		SET @NameArticleSecure = 'SAME DAY SEGURO'

		IF @Segment = 'FOR'
			SET @NameArticle = 'SAME DAY DELIVERY FORANEO'
		ELSE
			SET @NameArticle = 'SAME DAY DELIVERY LOCAL'
	END
	ELSE
	BEGIN
		SET @NameArticleWeight = 'NEXT DAY EXCEDENTE DE PESO'
		SET @NameArticleSecure = 'NEXT DAY SEGURO'

		IF @Segment = 'FOR'
			SET @NameArticle = 'NEXT DAY DELIVERY FORANEO'
		ELSE
			SET @NameArticle = 'NEXT DAY DELIVERY LOCAL'
	END

	INSERT INTO @BreakdownOfPayment
	SELECT Description, Amount
	FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] bdp
	WHERE bdp.IdCost = (
		SELECT TOP 1 IdCost FROM Cost WHERE ProductNumber = @ProductNumber ORDER BY IdCost DESC
	)

	SET @Amount = (SELECT PriceShippment FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber);

	IF @Amount IS NOT NULL AND @Amount > 0
	BEGIN
		
		IF (SELECT COUNT(*) FROM @BreakdownOfPayment) > 0
		BEGIN
			
			SET @AmountWeight = (SELECT Amount FROM @BreakdownOfPayment WHERE Description LIKE '%PESO%')

			IF @AmountWeight IS NOT NULL AND @AmountWeight > 0
			BEGIN
				SET @AmountWeight = @AmountWeight * 1.12
				SET @Amount = @Amount - @AmountWeight
			END

			SET @AmountSecure = (SELECT Amount FROM @BreakdownOfPayment WHERE Description LIKE '%SEGURO%')

			IF @AmountSecure IS NOT NULL AND @AmountSecure > 0
			BEGIN
				SET @AmountSecure = @AmountSecure * 1.12
				SET @Amount = @Amount - @AmountSecure
			END


			INSERT INTO @GuideDetail
			SELECT ca.SAPCode
				, ca.Name
				, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
				, @Amount
				, ca.Category
				, 1
			FROM CatArticleSAP ca
			WHERE ca.Name = @NameArticle


			IF @AmountWeight IS NOT NULL AND @AmountWeight > 0
				INSERT INTO @GuideDetail
				SELECT ca.SAPCode
					, ca.Name
					, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
					, @AmountWeight
					, ca.Category
					, 0
				FROM CatArticleSAP ca
				WHERE ca.Name = @NameArticleWeight

			IF @AmountSecure IS NOT NULL AND @AmountSecure > 0
				INSERT INTO @GuideDetail
				SELECT ca.SAPCode
					, ca.Name
					, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
					, @AmountSecure
					, ca.Category
					, 0
				FROM CatArticleSAP ca
				WHERE ca.Name = @NameArticleSecure

		END
		ELSE
		BEGIN
			INSERT INTO @GuideDetail
			SELECT ca.SAPCode
				, ca.Name
				, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
				, @Amount
				, ca.Category
				, 1
			FROM CatArticleSAP ca
			WHERE ca.Name = @NameArticle
		END

	END

	SELECT * FROM @GuideDetail



	SET NOCOUNT OFF;
END	