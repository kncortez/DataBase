
CREATE PROCEDURE [dbo].[spws_get_GetDataResourceSecure]
	-- Add the parameters for the stored procedure here
	@CodApp as varchar(50) = ''	
AS
BEGIN
	select  ECO.UserKey,
			ECO.SecretKey,
			ISNULL(Cast(ECO.IdCustomer as varchar),'') IdCustomer
	from DeliveryBackOffice.dbo.Ecommerce ECO WITH(NOLOCK)
	JOIN DeliveryBackOffice.dbo.Customer CUS WITH(NOLOCK) 
	on ECO.IdCustomer = CUS.IdCustomer
	where UserKey = @CodApp 	
END
