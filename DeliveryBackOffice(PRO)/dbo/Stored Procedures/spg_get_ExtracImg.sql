CREATE PROCEDURE [dbo].[spg_get_ExtracImg]
	-- Add the parameters for the stored procedure here
	--@GuideSerie NVARCHAR(2),
	--@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @Begin AS BIGINT = 0;
	SET NOCOUNT ON;
	SET @Begin = (Select IdDeliveryProof from ContImg)
    -- Insert statements for procedure here
	SELECT top 10 [ID],
		 [Guide_Number]
		,[Date_Photo]
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Dry]"))', 'varchar(max)')) AS Image_Dry
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Cold]"))', 'varchar(max)')) AS Image_Cold
		,(select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Incident]"))', 'varchar(max)')) AS Image_Incident
	FROM [DeliveryBackOffice].[dbo].[DeliveryProof] WITH (NOLOCK)
	--WHERE ID in (16294,16302,109424,109444)
	--WHERE ID in (16291)
    WHERE (Proof_Dry is not null or Proof_Cold is not null or Proof_Incident is not null)
	AND ID > @Begin
	--Print (@Begin)
	
END