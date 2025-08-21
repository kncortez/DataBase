USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetZigiData]    Script Date: 20/08/2025 11:21:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetZigiData]
  
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
    WHERE CONVERT(DATE, dtd.DateCreated) = CONVERT(DATE, GETDATE() - 1)
          AND dtd.StatusOrderId = 11
          AND
          (
              ord.IsCollect = 1
              OR ord.Collect_OnDelivery > 0
          )
    GROUP BY ord.Receiver_FirstName
           , ord.Receiver_Phone;

END

