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
		 SELECT TOP 1 Tbl1.IdCatProductCategory AS CatTypeSubscriptionId,tbl1.IdSubscription,SubscriptionName
		 ,Tbl1.SubscriptionDescription
		 ,IncludeCollect
		 FROM  
		 (
		 SELECT TOP 1 A4.IdCatProductCategory, A1.IdSubscription,A2.SubscriptionName
		 ,DiscountValue
		 ,CONVERT(NVARCHAR(50),A3.DiscountValue) + ' x%' [SubscriptionDescription]
		 ,1 [IncludeCollect] 
		 FROM DeliveryBackOffice.dbo.Subscription A1 WITH(NOLOCK)
		 INNER JOIN DeliveryBackOffice.dbo.CatSubscription A2 WITH(NOLOCK) 
		   ON A1.CatSubscriptionId = A2.IdCatSubscription
		 INNER JOIN DeliveryBackOffice.dbo.SubscriptionDiscountRange A3 WITH(NOLOCK)
		  ON A1.IdSubscription = A3.SubscriptionId AND A3.RowStatus = 1
		 INNER JOIN DeliveryBackOffice.dbo.CatProductCategory A4
		  ON A2.CatProductCategoryId = A4.IdCatProductCategory
		 WHERE A1.AccountId = @IdAccount
		 AND A1.RowStatus = 1 AND A1.CatTypeSubscriptionId = 1
		 AND CAST(A1.ExpirationDate AS DATE) >= CAST(GETDATE() AS DATE)
		  ORDER BY A3.DiscountValue DESC
		 )Tbl1		
		 
		 UNION
		 
		 SELECT TOP 1 Tbl1.IdCatProductCategory AS CatTypeSubscriptionId,tbl1.IdSubscription,SubscriptionName
		 ,Tbl1.SubscriptionDescription
		 ,IncludeCollect
		 FROM  
		 (
		 SELECT TOP 1 A3.IdCatProductCategory, A1.IdSubscription,A2.SubscriptionName
		 ,0 [DiscountValue]
		 ,'Envíos incluídos'  [SubscriptionDescription]
		 ,0 [IncludeCollect] 
		 FROM DeliveryBackOffice.dbo.Subscription A1 WITH(NOLOCK)
		 INNER JOIN DeliveryBackOffice.dbo.CatSubscription A2 WITH(NOLOCK) 
		   ON A1.CatSubscriptionId = A2.IdCatSubscription	
		  INNER JOIN DeliveryBackOffice.dbo.CatProductCategory A3
		  ON A2.CatProductCategoryId = A3.IdCatProductCategory
		 WHERE A1.AccountId = @IdAccount
		 AND A1.RowStatus = 1 AND A1.CatTypeSubscriptionId = 2
		 AND CAST(A1.ExpirationDate AS DATE) >= CAST(GETDATE() AS DATE) 
		 AND (A1.SubscriptionMaxServiceFixedValue - A1.ActualServiceCount) > 0
		  ORDER BY A1.IdSubscription ASC		 
		 )Tbl1	
		 
		 UNION
		 SELECT TOP 1 Tbl1.IdCatProductCategory AS CatTypeSubscriptionId,tbl1.IdMembership AS IdSubscription,tbl1.MembershipName AS SubscriptionName
		 ,Tbl1.SubscriptionDescription
		 ,0 IncludeCollect
		 FROM 
		 (
		  SELECT TOP 1 A3.IdCatProductCategory, A1.IdMembership, A2.MembershipName
		  ,0 [DiscountValue]
		  ,'Solo acumula puntos'  [SubscriptionDescription]
		  FROM Membership A1
		  INNER JOIN CatMembership A2
			ON A1.CatMembershipId = A2.IdCatMembership
		  INNER JOIN CatProductCategory A3
		    ON A2.CatProductCategoryId = A3.IdCatProductCategory
			LEFT JOIN DeliveryBackOffice.dbo.MembershipDiscountRange A4
		   ON A4.MembershipId = A1.IdMembership AND A4.RowStatus = 1
		  WHERE A1.AccountId = @IdAccount
		  AND A1.RowStatus = 1 AND A2.CatProductCategoryId = 2
		  AND CAST(A1.ExpirationDate AS DATE) >= CAST(GETDATE() AS DATE) 
		  AND 
		  (
		    A1.MembershipMaxServiceFixedValue >0 --si es de monto fijo
		  OR
		   (     A4.MembershipId IS NULL --si tiene % de descuento
		     AND A4.RowStatus = 1
		     AND A4.DiscountValue > 0
		  )
		  )
		 )Tbl1
		 
		
    END TRY
    BEGIN CATCH

        SELECT '-1'            'StatusCode'
             , ERROR_MESSAGE() 'Description';
    END CATCH;
END;