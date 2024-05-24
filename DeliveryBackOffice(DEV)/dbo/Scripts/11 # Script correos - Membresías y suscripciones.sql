SELECT TMP2.[Nombre completo],TMP2.[Dirección de Correo]
,IIF(R2.IdSubscription IS NULL,R3.MembershipName,R4.SubscriptionName) [último Beneficio]
,IIF(R2.IdSubscription IS NULL,IIF(R1.ExpirationDate>=GETDATE(),'Activo','Inactivo'),IIF(R2.ExpirationDate>=GETDATE(),'Activo','Inactivo')) [Si está activo o no]
FROM 
(
SELECT A1.UsrIdUser, A5.PerFirstName + ' ' + A5.PerLastName [Nombre completo]
,A1.UsrEmail [Dirección de Correo]
,MAX(TMP.IdMembership) IdMembership,MAX(TMP.IdSubscription) IdSubscription
--,IIF(TMP.IdSubscription IS NULL,TMP.MembershipName,TMP.SubscriptionName) [�ltimo Beneficio]
--,IIF(TMP.IdSubscription IS NULL,TMP.ExpirationDateMembership,TMP.ExpirationDateSubscription) [Esta activo]
--,TMP.*
FROM dbo.RegisterUser A1 WITH(NOLOCK)
INNER JOIN DeliveryBackOffice.dbo.Person A5 WITH(NOLOCK)
ON A5.PerIdPerson = A1.UsrIdUser
AND A5.PerRowStatus = 1
OUTER APPLY
 (
  SELECT  RuaIdUser,A2.IdMembership--,A6.MembershipName
  --,IIF(A2.ExpirationDate >=GETDATE(),'Activo','Inactivo') ExpirationDateMembership 
  ,A4.IdSubscription--,A9.SubscriptionName
  --,IIF(A4.ExpirationDate>=GETDATE(),'Activo','Inactivo') ExpirationDateSubscription 
  --,A2.ExpirationDate ExpirationDate1
  --,A4.ExpirationDate ExpirationDate2
  FROM dbo.Membership A2 WITH(NOLOCK) 
  INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A3 WITH(NOLOCK)
  ON A3.RuaIdAccount = A2.AccountId AND A3.RuaRowStatus = 1
  --INNER JOIN DeliveryBackOffice.dbo.CatMembership A6 WITH(NOLOCK)
  --ON A6.IdCatMembership = A2.CatMembershipId
  --INNER JOIN DeliveryBackOffice.dbo.Customer A7 WITH(NOLOCK)
  --ON A7.IdCustomer = A2.CustomerId
  --AND A7.IdCustomerType = 1 --es individual
  --INNER JOIN DeliveryBackOffice.dbo.Account A8 WITH(NOLOCK)
  --ON A8.AccIdAccount = A3.RuaIdAccount AND A8.AccRowStatus = 1
  LEFT JOIN DeliveryBackOffice.dbo.Subscription A4 WITH(NOLOCK)
  ON A4.MembershipId = A2.IdMembership 
  AND A4.RowStatus = 1
  --LEFT JOIN DeliveryBackOffice.dbo.CatSubscription A9 WITH(NOLOCK)
  --ON A9.IdCatSubscription = A4.CatTypeSubscriptionId
  WHERE A2.RowStatus = 1
  --ORDER BY A2.IdMembership DESC,A4.IdSubscription DESC
  --AND A1.UsrIdUser = A3.RuaIdUser 
  --ORDER BY A2.IdMembership DESC  
 )TMP
WHERE A1.UsrRowStatus = 1
AND TMP.RuaIdUser = A1.UsrIdUser
GROUP BY A1.UsrIdUser, A5.PerFirstName + ' ' + A5.PerLastName,A1.UsrEmail
--,IIF(TMP.IdSubscription IS NULL,TMP.MembershipName,TMP.SubscriptionName)
--,IIF(TMP.IdSubscription IS NULL,TMP.ExpirationDateMembership,TMP.ExpirationDateSubscription)
--AND A1.UsrEmail = 'bidcarh@gmail.com'
) AS TMP2
INNER JOIN DeliveryBackOffice.dbo.Membership R1 WITH(NOLOCK)
ON R1.IdMembership = TMP2.IdMembership
INNER JOIN DeliveryBackOffice.dbo.CatMembership R3 WITH(NOLOCK)
ON R3.IdCatMembership = R1.CatMembershipId
LEFT JOIN DeliveryBackOffice.dbo.Subscription R2 WITH(NOLOCK)
ON R2.MembershipId = R1.IdMembership
AND TMP2.IdSubscription = R2.IdSubscription
LEFT JOIN DeliveryBackOffice.dbo.CatSubscription R4 WITH(NOLOCK)
ON R4.IdCatSubscription = R2.CatSubscriptionId