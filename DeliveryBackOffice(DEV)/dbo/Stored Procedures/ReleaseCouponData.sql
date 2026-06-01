
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <01/06/2022>
-- Description:	< Desbloquear cupones cuando se indique quitar cupon >
-- =============================================
CREATE PROCEDURE [dbo].[ReleaseCouponData]
  -- Add the parameters for the stored procedure here
  @CouponSerie               NVARCHAR(20),
  @SystemOrigin              INT,
  @CustomerId                INT,
  @VisitPointClient          INT,
  @VisitPointClientPortfolio INT,
  @GuideSerie                NVARCHAR(2),
  @GuideNumber               INT,
  @Token                     VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET nocount ON;

	-- Manejo cuando dato viene vacio o es 0
	IF(@VisitPointClient = 0)
		SET @VisitPointClient = NULL
		
	IF(@VisitPointClientPortfolio = 0)
		SET @VisitPointClientPortfolio = NULL
	  
	-- Variables de respuesta
	DECLARE @JsonResponse NVARCHAR(MAX) = '';
	DECLARE @JsonBreakdown NVARCHAR(MAX) = '';

	DECLARE @CouponData AS TABLE
	(
		couponserie          NVARCHAR(20),
		couponfinaldate      DATETIME,
		couponpromoid        INT,
		couponvaluetipeid    INT,
		coupondiscounttypeid INT,
		couponvalue          INT
	)

	-- Variables de control de flujo
	DECLARE @ClientType INT
	DECLARE @ClientId INT

	DECLARE @ValueTipeName VARCHAR(20)
	DECLARE @TypeDiscountName VARCHAR(20)
	DECLARE @PromoValue INT
	
	DECLARE @PhoneOrigin NVARCHAR(50) = '';
	DECLARE @PhoneDestination NVARCHAR(50) = '';

	DECLARE @GuideIsImpersonated BIT = 0;

	-- Validar Cliente - Esto se podrá usar cuando sea necesario validar que el cupon no se pueda transferir
	SELECT 
		@ClientId = Ac.idcustomer
		,@ClientType = Cu.IdCustomerType
	FROM 
		dbo.account Ac WITH (nolock)
		INNER JOIN 
			dbo.customer Cu WITH (nolock)
			ON 
				Ac.idcustomer = Cu.idcustomer
	WHERE  
		Ac.accidaccount = @CustomerId

	BEGIN TRY
		-- Validación de cupón
		IF ( Rtrim(Ltrim(Isnull(@CouponSerie, ''))) <> '' )
		BEGIN

			-- Valor original de la guía y teléfono del remitente de la guía a aplicarle el cupon
			SELECT  
				@ClientId = Cu.IdCustomer
				,@ClientType = Cu.IdCustomerType
				,@PhoneDestination = RTRIM(LTRIM(ISNULL(DO.Sender_Phone,'')))
				,@VisitPointClient = IIF(DO.OriginSenderId IS NULL OR DO.OriginSenderId = 0, IIF(@ClientType = 2, DO.Sender_ID, NULL), DO.OriginSenderId)
			FROM
				dbo.deliveryorder DO WITH(NOLOCK)
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
					ON
						DO.Sender_ID = VPC.CodeOfReference
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
					ON
						ISNULL(DO.IdCustomer, VPC.CustomerID) = Cu.IdCustomer
			WHERE  
				DO.guide_serie = @GuideSerie
				AND 
				DO.guide_number = @GuideNumber

			-- Teléfono de la guía que origino el cupon
			SELECT  
				@PhoneOrigin = RTRIM(LTRIM(ISNULL(DO.Sender_Phone,'')))
			FROM
				DeliveryBackOffice.dbo.deliveryorder DO WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK)
					ON
						DO.Guide_Serie = PC.GuideSerieOrigin
						AND
						DO.Guide_Number = PC.GuideNumberOrigin
			WHERE  
				PC.PromoCouponSerie = @CouponSerie

			-- Obtener datos del cupon
			INSERT INTO 
				@CouponData
				(couponserie, couponfinaldate, couponpromoid, couponvaluetipeid, coupondiscounttypeid, couponvalue)
			SELECT 
				PC.PromoCouponSerie,
				PC.FinalActiveDate,
				PC.CatPromoId,
				PC.CatValueTypeId,
				PC.CatDiscountTypeId,
				PC.CouponValue
			FROM
				dbo.promocoupon PC WITH (nolock)
			WHERE
				-- Validar el usuario que lo genera
				(
					PC.CustomerOrigin = @ClientId
					AND
					(
						(
							-- Cliente individual e impersonado
							@ClientType = 3
						)
						OR
						(
							-- Express bajo cartera de clientes
							(PC.VisitPointClientOrigin = @VisitPointClient)
							AND
							(PC.VisitPointClientPortfolioOrigin = @VisitPointClientPortfolio)
						)
						OR
						(
							-- Express center en punto vacio
							PC.VisitPointClientOrigin = @VisitPointClient
							AND
							@PhoneOrigin = @PhoneDestination
						)
					)
				)
				-- Bloqueo de cupones
				AND
				( PC.GuideSerieDestination = @GuideSerie )
				AND
				( PC.GuideNumberDestination = @GuideNumber )
				AND
				-- Validaciones normales de cupones
				PC.redeemeddate IS NULL
				AND PC.promocouponserie = @CouponSerie
				AND PC.finalactivedate >= Getdate()
				AND PC.rowstatus = 1

			--Validar que hay datos
			IF( EXISTS(SELECT TOP 1 1 FROM @CouponData) )
			BEGIN

				-- Transacción interna para bloqueo de cupones
				BEGIN TRANSACTION Release_Coupon_Redemption
				BEGIN TRY

					UPDATE
						PromoC
					SET
						PromoC.GuideSerieDestination = NULL
						,PromoC.GuideNumberDestination = NULL
						,PromoC.TokenUpdated = @Token
						,PromoC.DateUpdated = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH(NOLOCK)
					WHERE
						PromoC.PromoCouponSerie = @CouponSerie

					COMMIT TRANSACTION Release_Coupon_Redemption;
			
					SET @JsonResponse =  
					( 
						SELECT STUFF(( 
							SELECT 
								',{' + 
									'"IdResult":200' + ',' +
									'"Message":"Cupon fue liberado correctamente."' + ',' +
									'"Coupon": { } ' +
								'}'
							FOR XML PATH(''), TYPE 
						) 
						.value('.', 'varchar(max)'),1,1,'' 
						)
					) 

				END TRY
				BEGIN CATCH

					ROLLBACK TRANSACTION Release_Coupon_Redemption;
					
					SET @JsonResponse =  
					( 
						SELECT STUFF(( 
							SELECT 
								',{' + 
									'"IdResult":401' + ',' +
									'"Message":"Cupon presenta problemas, intente de nuevo en unos momentos"' + ',' +
									'"messageError":"' + ERROR_MESSAGE() + '"' + ',' +
									'"Coupon": { } ' +
								'}'
							FOR XML PATH(''), TYPE 
						) 
						.value('.', 'varchar(max)'),1,1,'' 
						)
					) 

				END CATCH
			
			END
			ELSE
			BEGIN

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
						SELECT 
							',{' + 
								'"IdResult":408' + ',' +
								'"Message":"Cupon esta siendo utilizado por otro servicio, por favor, verifique su información."' + ',' +
								'"Coupon": { } ' +
							'}'
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 

			END
		END
		ELSE
		BEGIN
			-- Flujo para otro manejo de cupones que no sea por identificador del cupon
			-- En este caso: 26/05/2022 es un error que no se envie cupon
			
			SET @JsonResponse =  
			( 
				SELECT STUFF(( 
					SELECT 
						',{' + 
							'"IdResult":407' + ',' +
							'"Message":"Cupon no es valido, por favor verifique su información"' + ',' +
							'"Coupon": { } ' +
						'}'
					FOR XML PATH(''), TYPE 
				) 
				.value('.', 'varchar(max)'),1,1,'' 
				)
			) 

		END

		IF(@JsonResponse IS NULL)
		BEGIN
			
			SET @JsonResponse =  
			( 
				SELECT STUFF(( 
					SELECT 
						',{' + 
							'"IdResult":407' + ',' +
							'"Message":"Cupon no es valido, por favor verifique su información"' + ',' +
							'"Coupon": { } ' +
						'}'
					FOR XML PATH(''), TYPE 
				) 
				.value('.', 'varchar(max)'),1,1,'' 
				)
			) 

		END

		SELECT ('[' + @JsonResponse +  ']') JsonOutput 

	END TRY

	BEGIN CATCH

		SET @JsonResponse =  
		( 
			SELECT STUFF(( 
				SELECT 
					',{' + 
						'"IdResult":401' + ',' +
						'"Message":"Cupon presenta problemas, intente de nuevo en unos momentos"' + ',' +
						'"messageError":"' + ERROR_MESSAGE() + '"' + ',' +
						'"Coupon": { } ' +
					'}'
				FOR XML PATH(''), TYPE 
			) 
			.value('.', 'varchar(max)'),1,1,'' 
			)
		) 
			 
		select ('[' + @JsonResponse +  ']') JsonOutput 

		SELECT 0 [blnResult],
			Error_number()    AS [ErrorNumber],
			Error_severity()  AS [ErrorSeverity],
			Error_state()     AS [ErrorState],
			Error_procedure() AS [ErrorProcedure],
			Error_line()      AS [ErrorLine],
			Error_message()   AS [ErrorMessage];

	END CATCH;
END