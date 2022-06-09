
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-04>
-- Description:	<Verifica que existe un visit point asociando a un settlement
--				devolvera 0 si no hay ningun visit point asociado
--				devolvera 1 si existe un visit point asociado
--				devolvera >1 si exite mas de un visiti point asociado>
-- =============================================
create PROCEDURE [dbo].[spws_get_validate_vp_by_sellerdepot_customer]
	-- Add the parameters for the stored procedure here
		    @CodApp as nvarchar(50) = 'SIFDCECOM300720201459',
			@IdSellerDepot as bigint  = 1454,
			@IdMerchant as int = 6
AS
BEGIN
	
	SET NOCOUNT ON;

	
	BEGIN TRY  
			select count(*) AS result from SellerDepot sd
			inner join VisitPointClient vp on vp.CodeOfReference = sd.IdVisitPointClient and vp.CustomerID =@IdMerchant
			where sd.IdSellerDepot = @IdSellerDepot

			
	END TRY  
	BEGIN CATCH  
		SELECT   Cast(ERROR_NUMBER() as nvarchar) AS ErrorNumber  
				,Cast(ERROR_SEVERITY() as nvarchar) AS ErrorSeverity  
				,Cast(ERROR_STATE() as nvarchar) AS ErrorState  
				,Cast(ERROR_PROCEDURE() as nvarchar) AS ErrorProcedure  
				,Cast(ERROR_LINE() as nvarchar) AS ErrorLine  
				,Cast(ERROR_MESSAGE() as nvarchar) AS ErrorMessage;
		
	END CATCH;   

END
