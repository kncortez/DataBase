-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-17>
-- Description:	<Finaliza un carrito de compra>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Updated date:<2024-04-22>
-- Description:	<Validar si no existe registro de la guía en tabla DeliveryOrderPaymentDetail e insertarlo >
-- =============================================

CREATE PROCEDURE [dbo].[FinishServiceCartbyAccount]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @VoidedCart BIT = 0;

	DECLARE @CollectPaymentTime INT = (SELECT TOP 1 CPT.TimePlaId FROM [DeliveryBackOffice].[dbo].[CatPaymentTime] CPT WHERE CPT.TimePlaName = 'Destino' COLLATE Latin1_General_CI_AI);

	DECLARE @CountUpdated INT = 0;
	DECLARE @CountValid INT = 0;

	DECLARE @CartGuides AS TABLE(
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		INDEX INDX_TEMP_CartGuides_Guides NONCLUSTERED (GuideSerie, GuideNumber)
	);

	DECLARE @ValidCartGuides AS TABLE (
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		INDEX INDX_TEMP_ValidCartGuides_Guides NONCLUSTERED (GuideSerie, GuideNumber)
	);

	DECLARE @UpdatedGuidesInCart AS TABLE (
		IdUpdated INT
	);

	BEGIN TRANSACTION

	BEGIN TRY

	  -- Insertar registro en tabla DeliveryOrderPaymentDetail si este registro no existe
	       
		  INSERT INTO [dbo].[DeliveryOrderPaymentDetail]
            (
                [GuideNumber],
                [GuideSerie],
                [PayTypeId],
                [TypeofInOutMoneyId],
                [TimePlaId],
                [amount],
                [TokenCreated],
                [DateCreated],
                [TokenUpdated],
                [DateUpdated],
                [PaymentRecollections],
                [PaymentNow],
                [PaymentDelivery],
                [StartDate],
                [EndDate],
                [ShipmentCompleted],
                [RecollectionCompleted],
                [PaidGuide],
                [TransaccionFAC],
                [IdHeaderRecolection],
                [RecolectNow],
                [RecolectDelivery],
                [RecolectPayment]
           
            )
            SELECT CG.GuideNumber,
                   CG.GuideSerie,
                   CASE
                       WHEN do.IsCollect = 1 THEN
                       (
                           SELECT PayTypeId
                           FROM CatPaymentType WITH (NOLOCK)
                           WHERE PayTypeAbrev = 'COLLT'
                       )
                       WHEN cu.ConditionOfPaymentID > 1 THEN
                       (
                           SELECT PayTypeId
                           FROM CatPaymentType WITH (NOLOCK)
                           WHERE PayTypeAbrev = 'CREDT'
                       )
                       ELSE
                   (
                       SELECT PayTypeId
                       FROM CatPaymentType WITH (NOLOCK)
                       WHERE PayTypeAbrev = 'CONT'
                   )
                   END,
                   CASE
                       WHEN do.IsCollect = 1 THEN
                           1
                       WHEN cu.ConditionOfPaymentID > 1 THEN
                           8
                       ELSE
                           1
                   END,
                   CASE
                       WHEN do.IsCollect = 1 THEN
                       (
                           SELECT TimePlaId
                           FROM CatPaymentTime WITH (NOLOCK)
                           WHERE TimePlaAbrev = 'DEST'
                       )
                       WHEN cu.ConditionOfPaymentID > 1 THEN
                       (
                           SELECT TimePlaId
                           FROM CatPaymentTime WITH (NOLOCK)
                           WHERE TimePlaAbrev = 'POST'
                       )
                       ELSE
                   (
                       SELECT TimePlaId
                       FROM CatPaymentTime WITH (NOLOCK)
                       WHERE TimePlaAbrev = 'AHR'
                   )
                   END,
                   0,
                   @Token,
                   GETDATE(),
                   NULL,
                   NULL,
                   0,
                   0,
                   0,
                   NULL,
                   NULL,
                   0,
                   0,
                   0,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL
          
            FROM  @CartGuides CG
			    INNER JOIN [dbo].[DeliveryOrder] do WITH (NOLOCK)
				   ON CG.GuideSerie = do.Guide_Serie
				   AND CG.GuideNumber = do.Guide_Number
                INNER JOIN [dbo].[Customer] cu WITH (NOLOCK)
                    ON cu.IdCustomer =
                    (
                        SELECT TOP 1
                               ISNULL(do.IdCustomer, vpc.CustomerID)
                        FROM dbo.VisitPointClient vpc WITH (NOLOCK)
                        WHERE vpc.CodeOfReference = do.Sender_ID
                    )
				LEFT JOIN 
				[dbo].[DeliveryOrderPaymentDetail] dopd 
				ON CG.GuideSerie = dopd.GuideSerie AND 
				   CG.GuideNumber = dopd.GuideNumber
            WHERE DopId IS NULL

		-- Tomar guías del carrito
		INSERT INTO
			@CartGuides
			(GuideSerie, GuideNumber)
		SELECT
			DISTINCT
				AccSCD.GuideSerie,
				AccSCD.GuideNumber
		FROM
			DeliveryBackOffice.dbo.AccountServiceCart AccSC WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH(NOLOCK)
				ON
					AccSC.IdAccountServiceCart = AccSCD.AccountServiceCartId
					AND
					AccSCD.RowStatus = 1
		WHERE
			AccSC.AccountId = @IdAccount
			AND
			AccSC.IsPending = 1
			AND
			AccSC.RowStatus = 1

		-- Verificar guías validas, guías collect o confirmadas de pago en carrito de compras
		INSERT INTO
			@ValidCartGuides
			(GuideSerie, GuideNumber)
		SELECT
			DISTINCT
				CG.GuideSerie
				,CG.GuideNumber
		FROM
			@CartGuides CG
			LEFT JOIN -- Guías marcadas como collect
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH(NOLOCK)
				ON
					CG.GuideSerie = DOPD.GuideSerie
					AND
					CG.GuideNumber = DOPD.GuideNumber
					AND
					DOPD.TimePlaId = @CollectPaymentTime
			LEFT JOIN -- Guías en detalle de transacción bancaria
				[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomerDetail] CCTBCD WITH(NOLOCK)
				ON
					CG.GuideSerie = CCTBCD.SerieNumber
					AND
					CG.GuideNumber = CCTBCD.ProductNumber
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBCdet WITH(NOLOCK)
				ON
					CCTBCD.OrderNumber = CCTBCdet.OrderNumber
					AND
					CCTBCdet.ReasonCode = '00'
			LEFT JOIN -- Guías pagadas como número de orden
				[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBCmain WITH(NOLOCK)
				ON
					CONCAT(CG.GuideSerie, CG.GuideNumber) = CCTBCmain.OrderNumber
					AND
					CCTBCmain.ReasonCode = '00'
			LEFT JOIN -- Guías con membresia o suscripción y monto 0
				[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL WITH(NOLOCK)
				ON
					CG.GuideSerie = MSL.LogGuideSerie
					AND
					CG.GuideNumber = MSL.LogGuideNumber
					AND
					MSL.LogGuideNewValue = 0
		WHERE
			DOPD.DopId IS NOT NULL
			OR
			CCTBCdet.IdTransaction IS NOT NULL
			OR
			CCTBCmain.IdTransaction IS NOT NULL
			OR
			MSL.IdMembershipSubscriptionLog IS NOT NULL

     
		
		-- Actualizar guías validas que fueron procesadas
		UPDATE
			DOPD
		SET
			ShipmentCompleted = 1
		FROM
			DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK)
			INNER JOIN
				@ValidCartGuides CG
				ON
					DOPD.GuideSerie = CG.GuideSerie
					AND
					DOPD.GuideNumber = CG.GuideNumber

		-- Actualizar guías que si fueron procesadas o son collect
		UPDATE
			ASCD
		SET
			ASCD.RowStatus = 0
			,ASCD.DateUpdated = GETDATE()
			,ASCD.TokenUpdated = @Token
		OUTPUT
			inserted.IdAccountServiceCartDetail INTO @UpdatedGuidesInCart(IdUpdated)
		FROM
			DeliveryBackOffice.dbo.AccountServiceCartDetail ASCD WITH(NOLOCK)
			INNER JOIN
				@ValidCartGuides CG
				ON
					ASCD.GuideSerie = CG.GuideSerie
					AND
					ASCD.GuideNumber = CG.GuideNumber

		-- Conteo de guías actualizadas
		SELECT
			@CountUpdated = COUNT(IdUpdated)
		FROM
			@UpdatedGuidesInCart

		-- Conteo de guías validas en carrito
		SELECT
			@CountValid = COUNT(GuideNumber)
		FROM
			@CartGuides

		-- Si se puede finalizar el carrito de compras
		IF( @CountUpdated = @CountValid)
		IF(COUNT(@CountValid)>0)
		BEGIN
		
			UPDATE 
				DeliveryBackOffice.dbo.AccountServiceCart
			SET 
				IsPending = 0
				,DateUpdated = GETDATE()
				,TokenUpdated = @Token
			WHERE 
				AccountId = @IdAccount
				AND 
				IsPending = 1
				AND 
				RowStatus = 1

			-- Si actualizo el carrito exitosamente
			IF (@@ROWCOUNT > 0)
			BEGIN
				SET @VoidedCart = 1;
				SELECT
					1 'StatusCode'
					,'Service Cart finished successfully' 'Description'
			END
			ELSE
				SELECT
				2 'StatusCode'
			   ,'Service Cart not found' 'Description'
			
		END
		ELSE
		BEGIN

			SELECT
				1 'StatusCode'
				,'Service Cart partially finished' 'Description'

		END

		COMMIT TRANSACTION;

    END TRY
	BEGIN CATCH
		
		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';
				
		ROLLBACK TRANSACTION;
	END CATCH
END