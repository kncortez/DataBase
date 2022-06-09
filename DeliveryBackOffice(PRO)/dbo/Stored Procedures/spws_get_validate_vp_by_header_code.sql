
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-04>
-- Description:	<Verifica que existe un visit point asociando a un Hub
--				devolvera 0 si no hay ningun visit point asociado
--				devolvera 1 si existe un visit point asociado
--				devolvera >1 si exite mas de un visiti point asociado>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_validate_vp_by_header_code]
	-- Add the parameters for the stored procedure here
		    @CodApp as nvarchar(50) = 'SIFDCECOM300720201459',
			@HeaderCode as nvarchar(6)  = '0101'

AS
BEGIN
	
	SET NOCOUNT ON;

	
	BEGIN TRY  
			  select count(*) as result
				  from DeliveryBackOffice.dbo.Township mun WITH(NOLOCK)
					inner join DeliveryBackOffice.dbo.TownshipByHubLogistic muh WITH(NOLOCK) ON muh.IdTownship =  mun.IdTownship
					inner join DeliveryBackOffice.dbo.HubLogistics hub WITH(NOLOCK) on hub.IdHubLogistic =  muh.IdHublogistic
					inner join DeliveryBackOffice.dbo.VisitPointClientByHubLogistics vph WITH(NOLOCK) on vph.IdHublogistic = hub.IdHubLogistic
					inner join DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK) on vpc.CodeOfReference = vph.IdVisitPointClient
				  where mun.HeaderCode = @HeaderCode

			
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