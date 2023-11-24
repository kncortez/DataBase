-- =============================================
-- Author:		<Cano,Carlos>
-- Create date: <30-07-2020>
-- Description:	<Devuelve toda la información de un courier>
-- =============================================
CREATE procedure [dbo].[spg_courier_information]
	-- Add the parameters for the stored procedure here
	@CUI nvarchar(25)
as
begin
	select [ID]
      ,sr.[First_Name]
      ,sr.[Last_Name]
      ,sr.[Address]
      ,sr.[Zone]
      ,sr.[Town]
      ,sr.[Department]
      ,sr.[Phone]
      ,sr.[Social_Security_ID]
      ,sr.[Email]
      ,sr.[CUI]
      ,sr.[Latitude]
      ,sr.[Longitude]
      ,sr.[Entity_Type]
	  ,sr.[User_Created]
	  ,sr.[Date_Created]
	  ,sr.[Estatus]
	  ,sr.[CatTypeSenderReceiverId]
	  ,sr.[HubLogisticId]
	  ,srl.[LoginToken] as 'UniqueCode'
	  ,sr.[Email]
  FROM [DeliveryBackOffice].[dbo].[SenderReceiver] sr WITH(NOLOCK)
  LEFT JOIN SenderReceiverLoginToken srl WITH(NOLOCK)
  ON sr.ID = srl.SenderReceiverId
  AND srl.RowStatus = 1
  WHERE CUI = @CUI
  AND Entity_Type = 3
END