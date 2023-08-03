-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <2023-07-24>
-- Description:	<Tipos de suscripciones para un cliente>
-- =============================================
CREATE PROCEDURE [dbo].[ClientSubscriptionFetcher]
	@IdAccount INT = 0
AS
BEGIN
    BEGIN TRY
		  SELECT '1'                              'StatusCode'
             , 'Datos obtenidos correctamente.' 'Description';
			 
		 
		 --%Descuento
		 SELECT TOP 1 Tbl1.CatTypeSubscriptionId,tbl1.IdSubscription,SubscriptionName
		 ,Tbl1.SubscriptionDescription
		 ,IncludeCollect
		 FROM  
		 (
		 SELECT TOP 1 A1.CatTypeSubscriptionId, A1.IdSubscription,A2.SubscriptionName
		 ,DiscountValue
		 ,CONVERT(NVARCHAR(50),A3.DiscountValue) + ' x%' [SubscriptionDescription]
		 ,1 [IncludeCollect] 
		 FROM DeliveryBackOffice.dbo.Subscription A1 WITH(NOLOCK)
		 INNER JOIN DeliveryBackOffice.dbo.CatSubscription A2 WITH(NOLOCK) 
		   ON A1.CatSubscriptionId = A2.IdCatSubscription
		 INNER JOIN DeliveryBackOffice.dbo.SubscriptionDiscountRange A3 WITH(NOLOCK)
		  ON A1.IdSubscription = A3.SubscriptionId AND A3.RowStatus = 1
		 WHERE A1.AccountId = @IdAccount
		 AND A1.RowStatus = 1 AND A1.CatTypeSubscriptionId = 1
		 AND CAST(A1.ExpirationDate AS DATE) >= CAST(GETDATE() AS DATE)
		  ORDER BY A3.DiscountValue DESC
		 )Tbl1		
		 
		 UNION
		 
		 SELECT TOP 1 Tbl1.CatTypeSubscriptionId,tbl1.IdSubscription,SubscriptionName
		 ,Tbl1.SubscriptionDescription
		 ,IncludeCollect
		 FROM  
		 (
		 SELECT TOP 1 A1.CatTypeSubscriptionId, A1.IdSubscription,A2.SubscriptionName
		 ,0 [DiscountValue]
		 ,'Envíos incluídos'  [SubscriptionDescription]
		 ,0 [IncludeCollect] 
		 FROM DeliveryBackOffice.dbo.Subscription A1 WITH(NOLOCK)
		 INNER JOIN DeliveryBackOffice.dbo.CatSubscription A2 WITH(NOLOCK) 
		   ON A1.CatSubscriptionId = A2.IdCatSubscription		
		 WHERE A1.AccountId = @IdAccount
		 AND A1.RowStatus = 1 AND A1.CatTypeSubscriptionId = 2
		 AND CAST(A1.ExpirationDate AS DATE) >= CAST(GETDATE() AS DATE) 
		 AND (A1.SubscriptionMaxServiceFixedValue - A1.ActualServiceCount) > 0
		  ORDER BY A1.IdSubscription ASC		 
		 )Tbl1	
		 
		
    END TRY
    BEGIN CATCH

        SELECT '-1'            'StatusCode'
             , ERROR_MESSAGE() 'Description';
    END CATCH;
END;