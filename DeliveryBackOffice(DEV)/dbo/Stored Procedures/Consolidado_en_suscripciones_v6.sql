-- Detalle de Consumo Consolidado en suscripciones v6 (Julio 2024)
create procedure [dbo].[Consolidado_en_suscripciones_v6]
as
begin
	SELECT
		SUBQ.ID_Paquete,
		SUBQ.IdClubForza,
		SUBQ.NombrePaquete,
		SUBQ.Tipo,
		SUBQ.Costo,
		SUBQ.FechaAdquisicion,
		SUBQ.AnioMesAdquisicion,
		SUBQ.FechaExpiracion,
		SUBQ.NombreCliente,
		SUBQ.Correo,
		SUBQ.EnviosConsumidos,
		SUBQ.EnviosAdquiridos,
		SUBQ.AnioMesConsumo,
		COUNT(SUBQ.Fecha_Generacion) [VecesConsumido],
		SUBQ.Telefono,
		SUBQ.[STATUS]
	FROM 
	(
	SELECT ISNULL(SL.SubscriptionId, 0) [ID_Paquete],
		   'S' + CAST(S.IdSubscription AS NVARCHAR) [IdClubForza],
		   CS.SubscriptionName [NombrePaquete],
		   'Suscripción' [Tipo],
		   S.SubscriptionCost [Costo],
		   S.DateCreated [FechaAdquisicion],
		   FORMAT(S.DateCreated,'yyyy-MM') [AnioMesAdquisicion],
		   S.ExpirationDate [FechaExpiracion],
		   CM.[Name] [NombreCliente],
		   CM.UsrEmail [Correo],
		   IIF(S.CatTypeSubscriptionId = 1,
			   0,
			   IIF(S.ActualServiceCount - S.SubscriptionMaxServiceFixedValue > 0,
				   S.SubscriptionMaxServiceFixedValue, /*S.SubscriptionMaxServiceFixedValue-*/
				   S.ActualServiceCount)) [EnviosConsumidos],
		   IIF(S.CatTypeSubscriptionId = 1, 0, S.SubscriptionMaxServiceFixedValue) [EnviosAdquiridos],
		   ISNULL(SL.DateUpdated, SL.DateCreated) [Fecha_Generacion],
		   ISNULL(FORMAT(SL.DateUpdated,'yyyy-MM'), FORMAT(SL.DateCreated,'yyyy-MM')) [AnioMesConsumo],
		   CM.Phone [Telefono],
		   IIF(CAST(S.ExpirationDate AS DATE)<CAST(GETDATE() AS DATE),'Expirado','Vigente') [STATUS]
	FROM DeliveryBackOffice.dbo.Subscription S WITH (NOLOCK)
		LEFT JOIN dbo.MembershipSubscriptionLog SL WITH (NOLOCK)
			ON S.IdSubscription = SL.SubscriptionId -- 3,189 suscripciones al 31 de mayo 2024
		INNER JOIN DeliveryBackOffice.dbo.CatSubscription CS WITH (NOLOCK)
			ON S.CatSubscriptionId = CS.IdCatSubscription
		OUTER APPLY
	(
		SELECT TOP 1
			   P.PerFirstName + ' ' + P.PerLastName PerName,
			   RU.UsrEmail,
			   CTM.[Name],
			   RU.Phone [Phone]
		FROM DeliveryBackOffice.dbo.Customer CTM WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Account ACC
				ON ACC.IdCustomer = CTM.IdCustomer
			INNER JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH (NOLOCK)
				ON [ACC].AccIdAccount = RBUBA.RuaIdAccount
			INNER JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH (NOLOCK)
				ON [RU].[UsrIdUser] = [RBUBA].[RuaIdUser]
			INNER JOIN [DeliveryBackOffice].[dbo].[Person] P WITH (NOLOCK)
				ON [P].PerIdPerson = RU.UsrIdPerson
		WHERE CTM.IdCustomer = S.CustomerId
		ORDER BY 1 DESC
	) CM
	WHERE S.CatSubscriptionStatusId <> 4
		  AND SL.RowStatus = 1 -- guías no anuladas
		  AND SL.DateCreated >= '2023-11-01' --A partir del 23 octubre 2023 (ultimo esquema de prepago)

		  /*** VALORES DE PRUEBA ***/
		  --AND S.IdSubscription = 3234 --2867 --3300
		  --AND SL.DateCreated BETWEEN '2024-05-31' AND '2024-06-01'
		  --AND SL.SubscriptionId IN (3188,3393,2944,2993,2969,3054,3321,3271,748)
	) AS SUBQ
	GROUP BY SUBQ.ID_Paquete,
			 SUBQ.IdClubForza,
			 SUBQ.NombrePaquete,
			 SUBQ.Tipo,
			 SUBQ.Costo,
			 SUBQ.FechaAdquisicion,
			 SUBQ.AnioMesAdquisicion,
			 SUBQ.FechaExpiracion,
			 SUBQ.NombreCliente,
			 SUBQ.Correo,
			 SUBQ.EnviosConsumidos,
			 SUBQ.EnviosAdquiridos,
			 SUBQ.AnioMesConsumo,
			 SUBQ.Telefono,
			 SUBQ.[STATUS]
	--ORDER BY SUBQ.ID_Paquete
end