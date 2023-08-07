-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-07-31>
-- Description:	<Validar si existe número>
-- =============================================
CREATE procedure [dbo].[sphd_ValidateNumber]
@Phone nvarchar(50)
AS
BEGIN
		    
		IF EXISTS(SELECT TOP 1 1   FROM [DeliveryBackOffice].[dbo].[SenderReceiver] WHERE Phone = @Phone)
		BEGIN 

		  SELECT 1 AS 'StatusCode'
		
		END
		ELSE
		   SELECT 0 AS 'StatusCode'
		END