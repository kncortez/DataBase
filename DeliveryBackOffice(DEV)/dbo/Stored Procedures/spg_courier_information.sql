-- =============================================
-- Author:      <Cano,Carlos>
-- Create date: <30-07-2020>
-- Description: <Devuelve toda la información de un courier>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-18>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
create procedure [dbo].[spg_courier_information]
	-- Add the parameters for the stored procedure here
	@CUI nvarchar(25),
    @IdCountry NVARCHAR(2) = 'GT'
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
      ,ISNULL(sr.[IdCountry],'GT') AS IdCountry
  FROM [DeliveryBackOffice].[dbo].[SenderReceiver] sr WITH(NOLOCK)
  LEFT JOIN SenderReceiverLoginToken srl WITH(NOLOCK)
  ON sr.ID = srl.SenderReceiverId
  AND srl.RowStatus = 1
  WHERE CUI = @CUI
  AND Entity_Type = 3
  AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry
END