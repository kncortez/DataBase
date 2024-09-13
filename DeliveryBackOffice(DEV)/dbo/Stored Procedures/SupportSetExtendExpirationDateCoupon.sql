-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2023-07-07>
-- Description:	<Sp para dar de baja usuario corporativos>
-- =============================================

CREATE PROCEDURE [dbo].[SupportSetExtendExpirationDateCoupon]
 @CouponCode NVARCHAR(100)
  , @Token NVARCHAR(60)
  
  , @NewExpirationDate DATETIME
AS
BEGIN

IF EXISTS(SELECT * FROM dbo.PromoCoupon pr WHERE pr.PromoCouponSerie = @CouponCode)
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;


		UPDATE dbo.PromoCoupon
		SET	 FinalActiveDate = @NewExpirationDate
		, TokenUpdated = @Token
		, DateUpdated = GETDATE()
		
		WHERE PromoCouponSerie = @CouponCode


        COMMIT TRANSACTION;

		SELECT 'Tiempo extendido correctamente', pr.PromoCouponSerie , pr.FinalActiveDate
		FROM	 dbo.PromoCoupon  pr WHERE pr.PromoCouponSerie = @CouponCode
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER()
             , ERROR_PROCEDURE()
             , ERROR_STATE();
    END CATCH;
	END
	ELSE
	BEGIN
	    SELECT 'Cupón no exite '
	END
END;