-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2023-09-06>
-- Description:	<Reporte de membresias y suscripciones>
-- =============================================
CREATE PROCEDURE [dbo].[RDL_ReportMembershipSubscription]
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN

SET @StartDate = CAST(CONVERT(VARCHAR(10), @StartDate, 120) + ' 00:00:00' AS datetime);
SET @EndDate = CAST(CONVERT(VARCHAR(10), @EndDate, 120) + ' 23:59:59' AS datetime);


				SELECT  A1.IdMembership Id, 'M'+ CAST(A1.IdMembership AS NVARCHAR) [IdClubForza],A2.MembershipName [NombrePaquete],'Membresía'[Tipo]
				,A1.MembershipCost [Costo],A1.DateCreated [FechaCreacion]
				,A1.ExpirationDate [FechaExpiracion]
				,IIF(CAST(A1.ExpirationDate AS DATE)<CAST(GETDATE() AS DATE),'Expirado','Vigente') STATUS
				,A3.NAME [NombreCliente],A3.UsrEmail [Correo]
				,IIF(A1.DateCreated < '2023-08-25 00:00:00', --si es menor a la última fecha de publicación
				  IIF(A1.ActualServiceCount-A1.MembershipMaxServiceFixedValue>0,A1.ActualServiceCount-A1.MembershipMaxServiceFixedValue,0)
				  ,
				   --verificar si tiene un descuento vigente
				   iif((SELECT TOP 1 MDR.DiscountValue FROM DeliveryBackOffice.dbo.MembershipDiscountRange MDR WITH(NOLOCK) WHERE MDR.MembershipId = A1.IdMembership AND MDR.RowStatus =1 ORDER BY MDR.IdMembershipDiscountRange DESC)=0,0,
						0--IIF(A1.ActualServiceCount-A1.MembershipMaxServiceFixedValue>0,A1.ActualServiceCount-A1.MembershipMaxServiceFixedValue,0)
				   )

				  )  
				  [EnviosconDescuento]
				,IIF(A1.DateCreated < '2023-08-25 00:00:00',
					(SELECT TOP 1 MDR.DiscountValue FROM DeliveryBackOffice.dbo.MembershipDiscountRange MDR WITH(NOLOCK) WHERE MDR.MembershipId = A1.IdMembership ORDER BY MDR.IdMembershipDiscountRange DESC) 
					,0)
					[PorcentajeDeDescuentoAdquirido]
				,IIF(A1.ActualServiceCount-A1.MembershipMaxServiceFixedValue>0,A1.MembershipMaxServiceFixedValue,/*A1.MembershipMaxServiceFixedValue-*/A1.ActualServiceCount) [EnviosConsumidos]
				,A1.MembershipMaxServiceFixedValue [EnviosAdquiridos]
				,A1.AccumulatedPoints [PuntosAcumulados]
				,(SELECT COALESCE(SUM(COALESCE(PBS.PointsConsumed,0)),0) FROM DeliveryBackOffice.dbo.PointsByServiceLog PBS WITH(NOLOCK) WHERE PBS.MembershipId = A1.IdMembership AND PBS.RowStatus = 1) [PuntosRedimidos]
				,IHD.inv_pk_id
				,IHD.inv_certificationFEL
				,IHD.inv_SAPDocEntry
				,IHD.inv_SAPError
				,IIF(R2.TransactionOrder IS NOT NULL, 'Telemercadeo Visalink',
				   IIF(R2.[Authorization] IS NOT NULL,'Portal FAC','N/A'))
				[Donde se paga]
				,IIF(R2.[Authorization] IS NOT NULL,R2.[Authorization],R2.TransactionOrder) [Order]
				,R2.PaymentImageURL
				,A1.RowStatus
				--,A1.TokenCreated
				FROM DeliveryBackOffice.dbo.Membership A1 WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.CatMembership A2 WITH(NOLOCK) ON A2.IdCatMembership = A1.CatMembershipId
				OUTER APPLY
				(
				 SELECT	TOP 1 p.PerFirstName +' '+ p.PerLastName PerName 
				 ,ru.UsrEmail,ctm.Name
				 FROM DeliveryBackOffice.dbo.Customer CTM WITH(NOLOCK) 
				 INNER JOIN DeliveryBackOffice.dbo.Account ACC ON ACC.IdCustomer = CTM.IdCustomer
				  INNER JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH (NOLOCK)
							ON [Acc].AccIdAccount = RBUBA.RuaIdAccount
						INNER JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH (NOLOCK)
							ON [RU].[UsrIdUser] = [RBUBA].[RuaIdUser]
						INNER JOIN [DeliveryBackOffice].[dbo].[Person] P WITH (NOLOCK)
							ON [P].PerIdPerson = RU.UsrIdPerson
				 WHERE CTM.IdCustomer = A1.CustomerId
				 ORDER BY 1 DESC
				) A3 
				OUTER APPLY(
				 SELECT TOP 1 IHD.inv_pk_id,IHD.inv_certificationFEL,IHD.inv_SAPDocEntry,IHD.inv_SAPError 
				 FROM DeliveryBackOffice.dbo.invoiceHeader IHD WITH(NOLOCK)
				 INNER JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH(NOLOCK)
				 ON IHD.inv_pk_id = IND.dti_fk_header AND IND.MembershipId = A1.IdMembership
				) IHD
				OUTER APPLY
				(
				 SELECT TOP 1 R2.[Authorization],R2.TransactionOrder
				,R2.PaymentImageURL FROM DeliveryBackOffice.dbo.MembershipPaymentLog R2 WITH(NOLOCK)
				 WHERE R2.MembershipId = A1.IdMembership
				)R2
				WHERE 
				A1.DateCreated >= @StartDate--'2023-07-01 00:00:00'
				AND A1.DateCreated <= @EndDate--'2023-07-31 23:59:59'
				

				UNION
				SELECT
				A3.IdSubscription Id,'S' + CAST(A3.IdSubscription AS NVARCHAR) [IdClubForza],A4.SubscriptionName [NombrePaquete],'Suscripción'[Tipo]
				,A3.SubscriptionCost [Costo],A3.DateCreated [FechaCreacion]
				,A3.ExpirationDate [FechaExpiracion]
				,IIF(CAST(A3.ExpirationDate AS DATE)<CAST(GETDATE() AS DATE),'Expirado','Vigente') Status
				,A5.Name [NombreCliente],A5.UsrEmail [Correo]
				,IIF(A3.ActualServiceCount-IIF(A3.CatTypeSubscriptionId = 1,0,A3.SubscriptionMaxServiceFixedValue)>0,A3.ActualServiceCount-IIF(A3.CatTypeSubscriptionId = 1,0,A3.SubscriptionMaxServiceFixedValue),0)  [EnviosconDescuento]
				,(SELECT TOP 1 MDR.DiscountValue FROM DeliveryBackOffice.dbo.SubscriptionDiscountRange MDR WITH(NOLOCK) WHERE MDR.SubscriptionId = A3.IdSubscription ORDER BY MDR.IdSubscriptionDiscountRange desc) [PorcentajeDeDescuentoAdquirido]
				,IIF(A3.CatTypeSubscriptionId = 1,0,IIF(A3.ActualServiceCount-A3.SubscriptionMaxServiceFixedValue>0,A3.SubscriptionMaxServiceFixedValue,/*A3.SubscriptionMaxServiceFixedValue-*/A3.ActualServiceCount)) [EnviosConsumidos]
				,IIF(A3.CatTypeSubscriptionId = 1,0,A3.SubscriptionMaxServiceFixedValue) [EnviosAdquiridos]
				,0[PuntosAcumulados]
				,0 [PuntosRedimidos]
				,IHD.inv_pk_id
				,IHD.inv_certificationFEL
				,IHD.inv_SAPDocEntry
				,IHD.inv_SAPError
				,IIF(R1.TransactionOrder IS NOT NULL, 'Telemercadeo Visalink',
				   IIF(R1.[Authorization] IS NOT NULL,'Portal FAC','N/A'))
				[Donde se paga]
				,IIF(R1.[Authorization] IS NOT NULL,R1.[Authorization],R1.TransactionOrder) [Order]
				--,R1.[Authorization]
				,R1.PaymentImageURL
				,A3.RowStatus
				--,A3.TokenCreated
				FROM DeliveryBackOffice.dbo.Subscription A3 WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.CatSubscription A4 WITH(NOLOCK) ON A3.CatSubscriptionId = A4.IdCatSubscription
				OUTER APPLY
				(
				 SELECT	TOP 1 p.PerFirstName +' '+ p.PerLastName PerName 
				 ,ru.UsrEmail,ctm.Name
				 FROM DeliveryBackOffice.dbo.Customer CTM WITH(NOLOCK) 
				 INNER JOIN DeliveryBackOffice.dbo.Account ACC ON ACC.IdCustomer = CTM.IdCustomer
				  INNER JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH (NOLOCK)
							ON [Acc].AccIdAccount = RBUBA.RuaIdAccount
						INNER JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH (NOLOCK)
							ON [RU].[UsrIdUser] = [RBUBA].[RuaIdUser]
						INNER JOIN [DeliveryBackOffice].[dbo].[Person] P WITH (NOLOCK)
							ON [P].PerIdPerson = RU.UsrIdPerson
 
				 WHERE CTM.IdCustomer = A3.CustomerId
				 ORDER BY 1 desc
				) A5
				OUTER apply(
				 SELECT TOP 1 IHD.inv_pk_id, IHD.inv_certificationFEL,IHD.inv_SAPDocEntry,IHD.inv_SAPError 
				 FROM DeliveryBackOffice.dbo.invoiceHeader IHD WITH(NOLOCK)
				 INNER JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH(NOLOCK)
				 ON IHD.inv_pk_id = IND.dti_fk_header AND IND.SubscriptionId = A3.IdSubscription
				) IHD
				OUTER APPLY
				(
				 SELECT TOP 1 R1.[Authorization]
				,R1.PaymentImageURL,R1.TransactionOrder 
				 FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog R1 WITH(NOLOCK)
				 WHERE R1.SubscriptionId = A3.IdSubscription

				)R1
				WHERE 
				A3.DateCreated >= @StartDate--'2023-07-01 00:00:00'
				AND A3.DateCreated <= @EndDate--'2023-07-31 23:59:59'
				

END