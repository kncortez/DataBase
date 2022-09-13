DECLARE @NewPromo AS TABLE(
	NewPromoId INT
)

IF ( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatPromo] CP WITH(NOLOCK) WHERE CP.PromoDescription = 'Segunda guía a mitad de precio' COLLATE Latin1_General_CI_AI AND CP.RowStatus = 1) )
BEGIN

	INSERT INTO
		[DeliveryBackOffice].[dbo].[CatPromo] 
		(
			[PromoDescription]
			,[PromoWeight]
			,[StartPromoDate]
			,[FinishPromoDate]
			,[Monday]
			,[Tuesday]
			,[Wednesday]
			,[Thursday]
			,[Friday]
			,[Saturday]
			,[Sunday]
			,[CatValueTypeId]
			,[PromoValue]
			,[CatDiscountTypeId]
			,[RowStatus]
			,[DateCreated]
			,[TokenCreated]
			,[LimitPromoTime]
		) 
	OUTPUT inserted.IdPromo INTO @NewPromo (NewPromoId)
	VALUES 
		(
			N'Segunda guía a mitad de precio'											-- Descripción de promo
			, 10																		-- Peso de la promoción
			, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)							-- Inicio de mes de fecha
			, DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(EOMONTH(GETDATE()) AS DATETIME)))	-- Fin de mes de fecha
			, 0																			-- Lunes
			, 0																			-- Martes
			, 0																			-- Miercoles
			, 1																			-- Jueves
			, 1																			-- Viernes
			, 0																			-- Sabado
			, 0																			-- Domingo
			, 1																			-- Identificador de tipo de valor a descontar
			, CAST(50.00 AS Decimal(5, 2))												-- Cantidad de tipo de valor a descontar
			, 2																			-- Tipo de descuento a aplicar
			, 1																			-- Estado lógico
			, GETDATE()
			, N'SYS-ARUIZ'
			, CAST(24.00 AS Decimal(6, 2))
		)

	INSERT INTO
		[DeliveryBackOffice].[dbo].[PromoCoverage]
		(CatPromoId, CustomerTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT TOP 1
		NP.NewPromoId, 2, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		@NewPromo NP

END