 CREATE procedure [dbo].[consumo_suscripcionesv6] 
-- Detalle de Consumo en suscripciones v6 (Julio 2024) -- 157,982
as
BEGIN
	SELECT ISNULL(SL.SubscriptionId,0) [ID_Paquete]
	,'S' + CAST(S.IdSubscription AS NVARCHAR) [IdClubForza]
	,CS.SubscriptionName [NombrePaquete]
	,'Suscripción'[Tipo]
	,
	
	CAST(S.SubscriptionCost
	/CASE CS.IdCountry
            WHEN 'GT' THEN 1.12   -- Guatemala 12%
            WHEN 'SV' THEN 1.13   -- El Salvador 13%
            WHEN 'HN' THEN 1.15   -- Honduras 15%
            ELSE 1                -- Por seguridad
        END
		AS DECIMAL(14,2))
	[Costo]
	--,S.SubscriptionCost
	,S.DateCreated [FechaAdquisicion]
	,S.ExpirationDate [FechaExpiracion]
	,CM.[Name] [NombreCliente],CM.UsrEmail [Correo]
	,IIF(S.CatTypeSubscriptionId = 1,0,IIF(S.ActualServiceCount-S.SubscriptionMaxServiceFixedValue>0,S.SubscriptionMaxServiceFixedValue,/*S.SubscriptionMaxServiceFixedValue-*/S.ActualServiceCount)) [EnviosConsumidos]
	,IIF(S.CatTypeSubscriptionId = 1,0,S.SubscriptionMaxServiceFixedValue) [EnviosAdquiridos]
	,ISNULL(SL.DateUpdated,SL.DateCreated) [Fecha_Generacion]
	,CM.Phone [Telefono]
    ,CS.IdCountry
	FROM DeliveryBackOffice.dbo.Subscription S WITH(NOLOCK) 
	LEFT JOIN dbo.MembershipSubscriptionLog SL WITH(NOLOCK) ON S.IdSubscription = SL.SubscriptionId -- 3,189 suscripciones al 31 de mayo 2024
	INNER JOIN DeliveryBackOffice.dbo.CatSubscription CS WITH(NOLOCK) ON S.CatSubscriptionId = CS.IdCatSubscription
	OUTER APPLY
	(
	 SELECT	TOP 1 p.PerFirstName +' '+ p.PerLastName PerName 
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