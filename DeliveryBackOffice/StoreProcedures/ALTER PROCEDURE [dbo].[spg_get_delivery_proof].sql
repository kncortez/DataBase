USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_get_delivery_proof]    Script Date: 16/09/2020 11:16:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_delivery_proof]
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
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Incident]"))', 'varchar(max)')) AS Image_Incident
	FROM [DeliveryBackOffice].[dbo].[DeliveryProof]
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	ORDER BY Date_Photo DESC
END
GO


