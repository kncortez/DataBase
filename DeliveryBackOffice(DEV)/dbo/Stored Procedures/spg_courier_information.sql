-- =============================================
-- Author:      <Cano,Carlos>
-- Create date: <30-07-2020>
-- Description: <Devuelve toda la información de un courier>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-18>
-- Description: <Condicion para que valores con idCountry nulo, tomen por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_courier_information]
(
 @CUI       NVARCHAR(25),
 @idCountry NVARCHAR(2) = NULL
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
      AND ((ISNULL(@idCountry,'') <> ''
          AND ISNULL(@idCountry,'') <> 'GT'
          AND IdCountry = @idCountry)
          OR
          (ISNULL(@idCountry,'') <> ''
           AND @idCountry = 'GT'
           AND (IdCountry IS NULL
            OR IdCountry = 'GT'))
          OR
          (ISNULL(@idCountry,'') = ''
           AND IdCountry IS NULL))
      AND Entity_Type = 3
END