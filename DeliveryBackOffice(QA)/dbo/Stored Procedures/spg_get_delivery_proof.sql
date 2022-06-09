

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_delivery_proof]
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Top 1 [ID] 
		,[Date_Photo]
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Dry]"))', 'varchar(max)')) AS Image_Dry
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Cold]"))', 'varchar(max)')) AS Image_Cold
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Incident]"))', 'varchar(max)')) AS Image_Incident
	    , Path_Dry AS Path_Dry
		, Path_Cold AS Path_Cold
	FROM [DeliveryBackOffice].[dbo].[DeliveryProof]
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	ORDER BY Date_Photo DESC
END
