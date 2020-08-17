USE DeliveryBackOffice;
GO

/****** Object:  StoredProcedure [dbo].[sp_get_hop_vouchers]    Script Date: 4/08/2020 09:59:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Cano,Carlos>
-- Create date: <04/Agosto/2020>
-- Description:	<Listar sedes de clientes por país>
-- =============================================
CREATE PROCEDURE [dbo].[spg_visitpoint]
	-- Add the parameters for the stored procedure here
	@IdCountry VARCHAR(2)
	,@Active BIT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		IdVisitPointClient as ID
		,CodeOfReference as ID_Visitpoint_Delivery
		,DescriptionOfClient as Visitpoint_Name
		,StatusClient as Active
		,CountryId as ID_Country
		,VisitPointId as ID_Visitpoint_Denarius
	FROM DeliveryBackOffice.dbo.VisitPointClient vp
	WHERE 
		vp.CountryId = @IdCountry
		AND StatusClient = 1 
		AND StatusClient = @Active
	ORDER BY DescriptionOfClient ASC
END


GO


