

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
    SELECT TOP 1
           [ID],
           [Date_Photo],
           (
               SELECT CAST('' AS XML).value('xs:base64Binary(sql:column("[Proof_Dry]"))', 'varchar(max)')
           ) AS Image_Dry,
           (
               SELECT CAST('' AS XML).value('xs:base64Binary(sql:column("[Proof_Cold]"))', 'varchar(max)')
           ) AS Image_Cold,
           (
               SELECT CAST('' AS XML).value('xs:base64Binary(sql:column("[Proof_Incident]"))', 'varchar(max)')
           ) AS Image_Incident,
           Path_Dry AS Path_Dry,
           Path_Cold AS Path_Cold,
           Path_Incident AS Path_Incident
    FROM [DeliveryBackOffice].[dbo].[DeliveryProof] WITH (NOLOCK)
    WHERE Guide_Serie = @GuideSerie
          AND Guide_Number = @GuideNumber
    ORDER BY Date_Photo DESC;
END;
