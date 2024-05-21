-- =============================================
-- Author:      <Cano,Carlos>
-- Create date: <30-07-2020>
-- Description: <Devuelve toda la información de un courier>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-18>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_courier_information]
(
 @CUI       NVARCHAR(25),
 @IdCountry NVARCHAR(2) = 'GT'
)
AS
BEGIN
   SELECT [ID]
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
          ,srl.[LoginToken] AS 'UniqueCode'
          ,sr.[Email]
          ,ISNULL(sr.[IdCountry],'GT') AS IdCountry
     FROM [DeliveryBackOffice].[dbo].[SenderReceiver] sr WITH(NOLOCK)
          LEFT JOIN SenderReceiverLoginToken srl WITH(NOLOCK) ON sr.ID = srl.SenderReceiverId
                                                             AND srl.RowStatus = 1
    WHERE CUI = @CUI
      AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry
      AND Entity_Type = 3
END