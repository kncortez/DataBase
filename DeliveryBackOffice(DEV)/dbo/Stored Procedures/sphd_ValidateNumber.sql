-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-07-31>
-- Description:	<Validar si existe número>
-- =============================================
CREATE procedure [dbo].[sphd_ValidateNumber]
@Phone nvarchar(50),
@UniqueCode nvarchar(50)
AS
BEGIN
		
	BEGIN TRY	

			IF (@UniqueCode='0')	   
			BEGIN
						IF EXISTS(SELECT TOP 1 1   FROM [DeliveryBackOffice].[dbo].[SenderReceiver] WHERE Phone LIKE '%'+ @Phone + '%' )
						BEGIN 
						  SELECT 0 AS 'StatusCode'
		
						END
						ELSE
						BEGIN
						   SELECT 0 AS 'StatusCode'
						END
			END
			ELSE
			BEGIN
			
			IF EXISTS(SELECT TOP 1 1   FROM [DeliveryBackOffice].[dbo].[SenderReceiver] WHERE Phone LIKE '%'+ @Phone + '%')
						BEGIN 
						  SELECT 0 AS 'StatusCode'
		
						END
						ELSE
						BEGIN
						   SELECT 0 AS 'StatusCode'
						END



			END
		

	END TRY

	BEGIN CATCH
    -- Bloque de código donde se manejan las excepciones
    SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_NUMBER() AS ErrorNumber;
   END CATCH

END