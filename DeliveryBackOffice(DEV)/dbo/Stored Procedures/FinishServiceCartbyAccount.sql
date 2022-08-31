-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-17>
-- Description:	<Finaliza un carrito de compra>
-- =============================================
CREATE PROCEDURE [dbo].[FinishServiceCartbyAccount]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CartGuides AS TABLE(
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		INDEX INDX_TEMP_CartGuides_Guides NONCLUSTERED (GuideSerie, GuideNumber)
	);

	BEGIN TRANSACTION

	BEGIN TRY

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

		UPDATE
			DOPD
		SET
			ShipmentCompleted = 1
		FROM
			DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK)
			INNER JOIN
				@CartGuides CG
				ON
					DOPD.GuideSerie = CG.GuideSerie
					AND
					DOPD.GuideNumber = CG.GuideNumber

		UPDATE 
			DeliveryBackOffice.dbo.AccountServiceCart
		SET 
			IsPending = 0
		WHERE 
			AccountId = @IdAccount
			AND 
			IsPending = 1
			AND 
			RowStatus = 1

		IF (@@ROWCOUNT > 0)
		BEGIN
			SELECT
				1 'StatusCode'
				,'Service Cart finished successfully' 'Description'
		END
		ELSE
			SELECT
			2 'StatusCode'
		   ,'Service Cart not found' 'Description'
			
		IF (@@TRANCOUNT > 0)
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