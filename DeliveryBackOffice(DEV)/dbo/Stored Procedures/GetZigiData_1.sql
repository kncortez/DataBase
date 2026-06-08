CREATE PROCEDURE [dbo].[GetZigiData]
  
AS
BEGIN


    SELECT ord.Receiver_FirstName
         , ord.Receiver_Phone
         , COUNT(dtd.Guide_Number)
         , SUM(ord.Collect_OnDelivery + ord.PriceShippment)
    FROM dbo.DeliveryOrderDetail     dtd WITH (NOLOCK)
        INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
            ON ord.Guide_Serie = dtd.Guide_Serie
               AND ord.Guide_Number = dtd.Guide_Number
    WHERE CONVERT(DATE, dtd.DateCreated) = CONVERT(DATE, GETDATE())
          AND dtd.StatusOrderId = 11
          AND
          (
              ord.IsCollect = 1
              OR ord.Collect_OnDelivery > 0
          )
		  AND ord.ReceiverCountryId ='GT'
    GROUP BY ord.Receiver_FirstName
           , ord.Receiver_Phone;

END