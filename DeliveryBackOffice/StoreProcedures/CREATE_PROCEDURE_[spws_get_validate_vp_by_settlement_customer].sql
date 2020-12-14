USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_validate_vp_by_settlement_customer]    Script Date: 4/12/2020 16:02:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-04>
-- Description:	<Verifica que existe un visit point asociando a un settlement
--				devolvera 0 si no hay ningun visit point asociado
--				devolvera 1 si existe un visit point asociado
--				devolvera >1 si exite mas de un visiti point asociado>
-- =============================================
create PROCEDURE [dbo].[spws_get_validate_vp_by_settlement_customer]
	-- Add the parameters for the stored procedure here
		    @CodApp as nvarchar(50) = 'SIFDCECOM300720201459',
			@IdSettlement as bigint  = 1454,
			@IdMerchant as int = 6
AS
BEGIN
	
	SET NOCOUNT ON;

	
	BEGIN TRY  
			select count(*) as result from VisitPointClient vp
			where vp.IdSettlement =@IdSettlement and vp.CustomerID = @IdMerchant

			
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