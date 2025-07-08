 create procedure consumo_suscripcionesv6   
-- Detalle de Consumo en suscripciones v6 (Julio 2024) -- 157,982  
as  
begin  
 SELECT ISNULL(SL.SubscriptionId,0) [ID_Paquete]  
 ,'S' + CAST(S.IdSubscription AS NVARCHAR) [IdClubForza]  
 ,CS.SubscriptionName [NombrePaquete]  
 ,'Suscripción'[Tipo]  
 ,S.SubscriptionCost [Costo]  
 ,S.DateCreated [FechaAdquisicion]  
 ,S.ExpirationDate [FechaExpiracion]  
 ,CM.[Name] [NombreCliente],CM.UsrEmail [Correo]  
 ,IIF(S.CatTypeSubscriptionId = 1,0,IIF(S.ActualServiceCount-S.SubscriptionMaxServiceFixedValue>0,S.SubscriptionMaxServiceFixedValue,/*S.SubscriptionMaxServiceFixedValue-*/S.ActualServiceCount)) [EnviosConsumidos]  
 ,IIF(S.CatTypeSubscriptionId = 1,0,S.SubscriptionMaxServiceFixedValue) [EnviosAdquiridos]  
 ,ISNULL(SL.DateUpdated,SL.DateCreated) [Fecha_Generacion]  
 ,CM.Phone [Telefono]  
 FROM DeliveryBackOffice.dbo.Subscription S WITH(NOLOCK)   
 LEFT JOIN dbo.MembershipSubscriptionLog SL WITH(NOLOCK) ON S.IdSubscription = SL.SubscriptionId -- 3,189 suscripciones al 31 de mayo 2024  
 INNER JOIN DeliveryBackOffice.dbo.CatSubscription CS WITH(NOLOCK) ON S.CatSubscriptionId = CS.IdCatSubscription  
 OUTER APPLY  
 (  
  SELECT TOP 1 p.PerFirstName +' '+ p.PerLastName PerName   
  ,ru.UsrEmail,ctm.[Name],ru.Phone[Phone]  
  FROM DeliveryBackOffice.dbo.Customer CTM WITH(NOLOCK)   
  INNER JOIN DeliveryBackOffice.dbo.Account ACC WITH(NOLOCK) ON ACC.IdCustomer = CTM.IdCustomer  
   INNER JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH (NOLOCK)  
    ON [Acc].AccIdAccount = RBUBA.RuaIdAccount  
   INNER JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH (NOLOCK)  
    ON [RU].[UsrIdUser] = [RBUBA].[RuaIdUser]  
   INNER JOIN [DeliveryBackOffice].[dbo].[Person] P WITH (NOLOCK)  
    ON [P].PerIdPerson = RU.UsrIdPerson  
   
  WHERE CTM.IdCustomer = S.CustomerId  
  ORDER BY 1 desc  
 ) CM  
 WHERE   
 S.CatSubscriptionStatusId <>4  
 AND SL.RowStatus = 1 -- guías no anuladas  
 AND SL.DateCreated >= '2023-11-01' --A partir del 23 octubre 2023 (ultimo esquema de prepago)  
  
END  