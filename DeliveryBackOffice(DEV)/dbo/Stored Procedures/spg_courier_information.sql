-- =============================================
-- Author:		<Cano,Carlos>
-- Create date: <30-07-2020>
-- Description:	<Devuelve toda la información de un courier>
-- =============================================
CREATE PROCEDURE [dbo].[spg_courier_information]
	-- Add the parameters for the stored procedure here
	@CUI NVARCHAR(25)
AS
BEGIN
	SELECT [ID]
      ,[First_Name]
      ,[Last_Name]
      ,[Address]
      ,[Zone]
      ,[Town]
      ,[Department]
      ,[Phone]
      ,[Social_Security_ID]
      ,[Email]
      ,[CUI]
      ,[Latitude]
      ,[Longitude]
      ,[Entity_Type]
	  ,[User_Created]
	  ,[Date_Created]
	  ,[Estatus]
	  ,[CatTypeSenderReceiverId]
	  ,[HubLogisticId]
	  ,[UniqueCode]
	  ,[Email]
  FROM [DeliveryBackOffice].[dbo].[SenderReceiver]
  WHERE CUI = @CUI
  AND Entity_Type = 3
END
