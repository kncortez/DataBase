CREATE PROCEDURE [dbo].[GetZigiData]  
    
AS  
BEGIN  
  
  
  
SELECT ord.Receiver_FirstName , ord.Receiver_Phone , COUNT(dtd.Guide_Number), SUM(ord.Collect_OnDelivery) FROM dbo.DeliveryOrderDetail dtd WITH(NOLOCK)  
 INNER JOIN dbo.DeliveryOrder ord WITH(NOLOCK) ON ord.Guide_Serie = dtd.Guide_Serie AND ord.Guide_Number = dtd.Guide_Number  
WHERE CONVERT(DATE, dtd.DateCreated) = CONVERT(DATE, GETDATE()-1)  
AND dtd.StatusOrderId = 11  
AND (ord.IsCollect = 1  
or ord.Collect_OnDelivery >0)  
  
GROUP BY ord.Receiver_FirstName , ord.Receiver_Phone  
  
END  
  