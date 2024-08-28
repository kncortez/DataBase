-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-19>
-- Description:	<SP para busqueda de ultimas 5 guías por medio de Número de teléfono para proyecto de contact center  >
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-19>
-- Description:	<SP Modificar filtro para que muestre todas las guías sin esepción de estados 5 y 22, agregar parametro FechaEntrega>
-- =============================================
CREATE PROCEDURE [dbo].[GetGuideFromPhoneNumberFCCTracking] 
@Phone AS NVARCHAR(20)
AS
BEGIN
DECLARE @es NVarChar(1) SET @es = ''
DECLARE @p1 NVarChar(10) SET @p1 = '(+502)'
DECLARE @p2 NVarChar(10) SET @p2 = '(502)'
DECLARE @p3 NVarChar(10) SET @p3 = '502'
DECLARE @p4 NVarChar(10) SET @p4 = '-'

IF (SELECT LEN(@Phone) ) > 8
   BEGIN
		SET @Phone = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(@Phone ,  
									       	   @p1, @es ),@p2,@es),@p3 ,@es),@p4,@es ))); 
	END;

	SELECT  DISTINCT TOP 5
		         DO.Sender_FirstName +' '+ DO.Sender_LastName AS SENDER_NAME
				,DO.Sender_Address
				,DO.Sender_Phone
				,ISNULL(DO.Sender_Mail,'N/D') AS Sender_Mail
				,DO.Guide_Serie
				,DO.Guide_Number
				,DO.StatusOrderId
				,SO.OrderDescription
				,DO.DateCreated
				,CASE
				     WHEN DOD.StatusOrderId IN(5,22)   THEN FORMAT(DOD.DateCreated,'dd-MM-yyyy' )
					 ELSE ''
					 END  AS FechaEntrega
				, CASE
				      WHEN DO.StatusOrderId NOT IN(5,22) THEN 'Pendiente de Finalizar' 
				  ELSE 'Servicio Finalizado' END StatusService
				, CASE 
				      WHEN DOD.StatusOrderId = 11 THEN Convert(varchar,DOD.DateCreated, 103)
				  ELSE  'Pendiente de Arribo' END AS FechaArribo
				,(SELECT HH.HubName FROM DeliveryBackOffice.dbo.HubLogistics HH
							WHERE HubAbbreviation = (SELECT TOP 1 D.Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage D
							  WHERE HeaderCode = (SELECT HeaderCode FROM DeliveryBackOffice.dbo.Township
												  WHERE IdTownship = DO.SenderIdTownship)))  AS HubName
				,ISNULL(DO.PriceShippment,0) AS Price 
				,ISNULL(DO.Collect_OnDelivery,0) AS COD
				,CASE
				     WHEN DATEDIFF(DAY, GETDATE(), isnull(DO.Delivery_Max_Date,GETDATE())) < 0 AND DO.StatusOrderId NOT IN(5,22) THEN 'Guia fuera de Tiempo, días de atraso :' +CAST(DATEDIFF(DAY, GETDATE(), isnull(DO.Delivery_Max_Date,GETDATE())) AS nvarchar)   
				ELSE  'Guía en tiempo' END TiempoEntrega
				,ISNULL(DO.Package_Description, 'Sin descripción') AS Package_Description
				,ISNULL(SO.OrderDescription,'N/D') AS CheckPointRastreo
				,ISNULL(DCBA.DCBA_Nom_account,'N/D')  AS NameAcount
				,ISNULL(DCBA.DCBA_BankAccountType,'N/D') AS BankAccountType
				,ISNULL(DB.Acronym,'N/D') AS Bank
		From 
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DOD WITH (NOLOCK)
			ON 
			DO.Guide_Serie=DOD.Guide_Serie AND DO.Guide_Number =DOD.Guide_Number
			INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
			ON 
			DOD.StatusOrderId = SO.StatusOrderId
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH (NOLOCK)
			ON 
			DO.DCBA_ID = DCBA.DCBA_Id
			LEFT JOIN DBO.DeliveryBank DB WITH (NOLOCK)
			ON  
			DCBA.DCBA_Bank_Id =DB.Id_bank
		WHERE 
		  SUBSTRING(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE( DO.Sender_Phone ,
		  @p1, @es ),@p2,@es),@p3 ,@es),@p4,@es ))),0,7) = SUBSTRING(@Phone,0,7)  	
		ORDER BY
			DO.DateCreated DESC

END