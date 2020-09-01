USE DeliveryBackOffice;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Carlos,Cano>
-- Create date: <10 Agosto 2020>
-- Description:	<Obtiene todas las imágenes encontradas para la guía provista>
-- =============================================
CREATE PROCEDURE spg_get_delivery_proof
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [ID]
		,[Date_Photo]
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Dry]"))', 'varchar(max)')) AS Image_Dry
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Cold]"))', 'varchar(max)')) AS Image_Cold
	FROM [DeliveryBackOffice].[dbo].[DeliveryProof]
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
END
GO
