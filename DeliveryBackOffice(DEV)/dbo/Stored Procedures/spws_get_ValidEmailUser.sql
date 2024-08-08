-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-07-24>
-- Description:	<Validar si el correo tiene cuenta y esa cuenta pertenece al país de compra>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_ValidEmailUser]
	@Email VARCHAR(100),
	@CountryId VARCHAR(3) = 'GT'

AS
BEGIN
	SET NOCOUNT ON;

  DECLARE	@IdCountryOrigin  VARCHAR(3) = (SELECT TOP 1  
												  CASE WHEN LEFT(ISNULL(UsrCurrency,'GT'),2)='HN' 
												      THEN 'HN' ELSE 'GT' END  
									                  FROM [DeliveryBackOffice].[dbo].[RegisterUser] WHERE UsrEmail = @Email)
  
     
	 IF(
	      EXISTS(SELECT TOP 1  
									1
					 FROM [DeliveryBackOffice].[dbo].[RegisterUser] WHERE UsrEmail = @Email)
	  )
	  BEGIN
		IF(@IdCountryOrigin = @CountryId)
		BEGIN
		      SELECT 1 AS 'IsValid'
		END
		  ELSE
		      SELECT 0 AS 'IsValid'
	  END 
	     ELSE
			SELECT 1 AS 'IsValid'


END