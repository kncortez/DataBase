
/* =================================================
   SP:        [dbo].[GetDepositReportCOD_Generic]
   Propósito: Para obtener la información del Informe de depositos por entregas realizadas.
   Autor:     Walter Orozco
   Historia:  FDAPI-5247 [FDAPI-5252]
   Fecha:     2025-12-12
 ============ CHANGELOG ============================
2021-10-19 | Historia/épica: Desconocido | Autor: Marco Jiménez	  |
2024-07-15 | Historia/épica: Desconocido | Autor: Cristian Suazo  |
=========================================== */

CREATE PROCEDURE [dbo].[GetDepositReportCOD_Generic]
    @IdCustomer		INT = -1
  , @IdBank			INT = -1
  , @StarDate		DATETIME
  , @EndDate		DATETIME
  , @Option			INT = -1
  , @SenderEmail	VARCHAR(MAX) = '0'
  , @ResultSet		INT = -1
AS
BEGIN

BEGIN TRY

    SET NOCOUNT ON;

	IF @Option <> -1
    BEGIN
		RETURN;
	END;

	IF (@IdCustomer != -1)
	BEGIN

		IF (@IdBank = -1)
		BEGIN

			IF (@ResultSet = 1 OR @ResultSet = -1)
			BEGIN
				;WITH H AS
				(
					SELECT
						h.IdDepositReportCODHeader,
						h.Customer_Id				AS IdCliente,
						h.Customer_Name				AS Cliente,
						h.Customer_Email			AS Correo,
						h.BankName					AS Banco,
						h.AccountNumber				AS Cuenta,
						h.AuthorizationNumber		AS NoDeposito,
						h.AuthorizationDate,
						h.Currency_Symbol			AS CurrencySymbol
					FROM DeliveryBackOffice.dbo.DepositReportCODHeader h WITH (NOLOCK)
					WHERE h.Customer_Id = @IdCustomer
					AND h.AuthorizationDate >= @StarDate 
					AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				)
				-- =======================
				--		   HEADER
				-- =======================
				SELECT
					H.IdDepositReportCODHeader,
					H.IdCliente,
					H.Cliente,
					H.Correo,
					H.Banco,
					H.Cuenta,
					H.NoDeposito,
					FORMAT(H.AuthorizationDate,'dd/MM/yyyy hh:mm:ss tt') AS FechaPago,
					H.AuthorizationDate,
					CONVERT(VARCHAR(10), @StarDate, 103) + ' - ' + CONVERT(VARCHAR(10), @EndDate, 103) AS DateDelivery,
					H.CurrencySymbol
				FROM H
				ORDER BY H.AuthorizationDate ASC;
			END
			IF (@ResultSet = 2 OR @ResultSet = -1)
			BEGIN
				-- =======================
				--		  DETAIL
				-- =======================
				SELECT
					d.IdDepositReportCODHeader,
					CONCAT(d.GuideSerie, d.GuideNumber)								AS GuideNumber,
					ISNULL(d.Pieces_Dry,0) + ISNULL(d.Pieces_Cold,0)				AS Piezas,
					d.TotalWeight													AS Peso,
					d.Department_Name												AS Departamento,
					d.Township_Name													AS Municipio,
					CONCAT(d.Receiver_FirstName,' ',d.Receiver_LastName)			AS Receiver,
					FORMAT(d.ArrivalDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaArribo,
					FORMAT(d.DeliveryDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaEntrega,
					d.ArrivalDate,
					d.DeliveryDate,
					d.Collect_OnDelivery											AS CODAmount,
					IIF(d.TypeService = 'EXP','NDD',ISNULL(d.TypeService,'NDD'))	AS TypeService,
					CASE
						WHEN d.IsCollect = 1 THEN 'Collect'
						WHEN ISNULL(d.ConditionOfPaymentID,0) > 1 THEN 'Crédito'
						ELSE 'Prepago'
					END																AS TipodePago,
					d.PriceShippment												AS ShippmentAmount,
					d.Commission													AS CommissionAmount,
					d.CODCommissionPercentage										AS PorcentajeComision,
					d.Amount + ISNULL(d.Commission,0)								AS ChargedAmount,
					d.Amount														AS TotalAmount,
					IIF(h.Bank_Id IN (3,5,31,33,1),1,0)								AS FlagImmediateOrAch,
					h.AuthorizationDate,
					DATEDIFF(DAY, d.ArrivalDate, d.DeliveryDate)					AS DiasEntrega,
					DATEDIFF(DAY, d.DeliveryDate, h.AuthorizationDate)				AS DiasPago
				FROM DeliveryBackOffice.dbo.ProcessedGuideCODNotifications	d	WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.DepositReportCODHeader	h	WITH (NOLOCK)
					ON h.IdDepositReportCODHeader = d.IdDepositReportCODHeader
				WHERE h.Customer_Id = @IdCustomer
				AND h.AuthorizationDate >= @StarDate 
				AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				ORDER BY h.AuthorizationDate ASC, d.IdDepositReportCODHeader, d.GuideSerie, d.GuideNumber;
			END
		END
		ELSE
		BEGIN
			IF (@ResultSet = 1 OR @ResultSet = -1)
			BEGIN
				;WITH H AS
				(
					SELECT
						h.IdDepositReportCODHeader,
						h.Customer_Id				AS IdCliente,
						h.Customer_Name				AS Cliente,
						h.Customer_Email			AS Correo,
						h.BankName					AS Banco,
						h.AccountNumber				AS Cuenta,
						h.AuthorizationNumber		AS NoDeposito,
						h.AuthorizationDate,
						h.Currency_Symbol			AS CurrencySymbol
					FROM DeliveryBackOffice.dbo.DepositReportCODHeader h WITH (NOLOCK)
					WHERE h.Customer_Id = @IdCustomer
					AND h.Bank_Id = @IdBank
					AND h.AuthorizationDate >= @StarDate 
					AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				)
				-- =======================
				--		   HEADER
				-- =======================
				SELECT
					H.IdDepositReportCODHeader,
					H.IdCliente,
					H.Cliente,
					H.Correo,
					H.Banco,
					H.Cuenta,
					H.NoDeposito,
					FORMAT(H.AuthorizationDate,'dd/MM/yyyy hh:mm:ss tt') AS FechaPago,
					H.AuthorizationDate,
					CONVERT(VARCHAR(10), @StarDate, 103) + ' - ' + CONVERT(VARCHAR(10), @EndDate, 103) AS DateDelivery,
					H.CurrencySymbol
				FROM H
				ORDER BY H.AuthorizationDate ASC;
			END
			IF (@ResultSet = 2 OR @ResultSet = -1)
			BEGIN
				-- =======================
				--		  DETAIL
				-- =======================
				SELECT
					d.IdDepositReportCODHeader,
					CONCAT(d.GuideSerie, d.GuideNumber)								AS GuideNumber,
					ISNULL(d.Pieces_Dry,0) + ISNULL(d.Pieces_Cold,0)				AS Piezas,
					d.TotalWeight													AS Peso,
					d.Department_Name												AS Departamento,
					d.Township_Name													AS Municipio,
					CONCAT(d.Receiver_FirstName,' ',d.Receiver_LastName)			AS Receiver,
					FORMAT(d.ArrivalDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaArribo,
					FORMAT(d.DeliveryDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaEntrega,
					d.ArrivalDate,
					d.DeliveryDate,
					d.Collect_OnDelivery											AS CODAmount,
					IIF(d.TypeService = 'EXP','NDD',ISNULL(d.TypeService,'NDD'))	AS TypeService,
					CASE
						WHEN d.IsCollect = 1 THEN 'Collect'
						WHEN ISNULL(d.ConditionOfPaymentID,0) > 1 THEN 'Crédito'
						ELSE 'Prepago'
					END																AS TipodePago,
					d.PriceShippment												AS ShippmentAmount,
					d.Commission													AS CommissionAmount,
					d.CODCommissionPercentage										AS PorcentajeComision,
					d.Amount + ISNULL(d.Commission,0)								AS ChargedAmount,
					d.Amount														AS TotalAmount,
					IIF(h.Bank_Id IN (3,5,31,33,1),1,0)								AS FlagImmediateOrAch,
					h.AuthorizationDate,
					DATEDIFF(DAY, d.ArrivalDate, d.DeliveryDate)					AS DiasEntrega,
					DATEDIFF(DAY, d.DeliveryDate, h.AuthorizationDate)				AS DiasPago
				FROM DeliveryBackOffice.dbo.ProcessedGuideCODNotifications	d	WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.DepositReportCODHeader	h	WITH (NOLOCK)
					ON h.IdDepositReportCODHeader = d.IdDepositReportCODHeader
				WHERE h.Customer_Id = @IdCustomer
				AND h.Bank_Id = @IdBank
				AND h.AuthorizationDate >= @StarDate 
				AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				ORDER BY h.AuthorizationDate ASC, d.IdDepositReportCODHeader, d.GuideSerie, d.GuideNumber;
			END
		END

	END
	ELSE IF (@SenderEmail != '-1')
	BEGIN

		IF (@IdBank = -1)
		BEGIN

			IF (@ResultSet = 1 OR @ResultSet = -1)
			BEGIN
				;WITH H AS
				(
					SELECT
						h.IdDepositReportCODHeader,
						h.Customer_Id					AS IdCliente,
						h.Customer_Name					AS Cliente,
						h.Sender_Email					AS Correo,
						h.BankName						AS Banco,
						h.AccountNumber					AS Cuenta,
						h.AuthorizationNumber			AS NoDeposito,
						h.AuthorizationDate,
						h.Currency_Symbol				AS CurrencySymbol
					FROM dbo.DepositReportCODHeader h WITH (NOLOCK)
					WHERE h.Sender_Email = @SenderEmail
					AND h.AuthorizationDate >= @StarDate 
					AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				)
				-- =======================
				--		   HEADER
				-- =======================
				SELECT
					H.IdDepositReportCODHeader,
					H.IdCliente,
					H.Cliente,
					H.Correo,
					H.Banco,
					H.Cuenta,
					H.NoDeposito,
					FORMAT(H.AuthorizationDate,'dd/MM/yyyy hh:mm:ss tt') AS FechaPago,
					H.AuthorizationDate,
					CONVERT(VARCHAR(10), @StarDate, 103) + ' - ' + CONVERT(VARCHAR(10), @EndDate, 103) AS DateDelivery,
					H.CurrencySymbol
				FROM H
				ORDER BY H.AuthorizationDate ASC;
			END
			IF (@ResultSet = 2 OR @ResultSet = -1)
			BEGIN
				-- =======================
				--		   DETAIL
				-- =======================
				SELECT
					d.IdDepositReportCODHeader,
					CONCAT(d.GuideSerie, d.GuideNumber)								AS GuideNumber,
					ISNULL(d.Pieces_Dry,0) + ISNULL(d.Pieces_Cold,0)				AS Piezas,
					d.TotalWeight													AS Peso,
					d.Department_Name												AS Departamento,
					d.Township_Name													AS Municipio,
					CONCAT(d.Receiver_FirstName,' ',d.Receiver_LastName)			AS Receiver,
					FORMAT(d.ArrivalDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaArribo,
					FORMAT(d.DeliveryDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaEntrega,
					d.ArrivalDate,
					d.DeliveryDate,
					d.Collect_OnDelivery											AS CODAmount,
					IIF(d.TypeService = 'EXP','NDD',ISNULL(d.TypeService,'NDD'))	AS TypeService,
					CASE
						WHEN d.IsCollect = 1 THEN 'Collect'
						WHEN ISNULL(d.ConditionOfPaymentID,0) > 1 THEN 'Crédito'
						ELSE 'Prepago'
					END																AS TipodePago,
					d.PriceShippment												AS ShippmentAmount,
					d.Commission													AS CommissionAmount,
					d.CODCommissionPercentage										AS PorcentajeComision,
					d.Amount + ISNULL(d.Commission,0)								AS ChargedAmount,
					d.Amount														AS TotalAmount,
					IIF(h.Bank_Id IN (3,5,31,33,1),1,0)								AS FlagImmediateOrAch,
					h.AuthorizationDate,
					DATEDIFF(DAY, d.ArrivalDate, d.DeliveryDate)					AS DiasEntrega,
					DATEDIFF(DAY, d.DeliveryDate, h.AuthorizationDate)				AS DiasPago
				FROM dbo.ProcessedGuideCODNotifications d WITH (NOLOCK)
				INNER JOIN dbo.DepositReportCODHeader h WITH (NOLOCK)
					ON h.IdDepositReportCODHeader = d.IdDepositReportCODHeader
				WHERE h.Sender_Email = @SenderEmail
				AND h.AuthorizationDate >= @StarDate 
				AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				ORDER BY h.AuthorizationDate ASC, d.IdDepositReportCODHeader, d.GuideSerie, d.GuideNumber;
			END
		END
		ELSE
		BEGIN
			IF (@ResultSet = 1 OR @ResultSet = -1)
			BEGIN
				;WITH H AS
				(
					SELECT
						h.IdDepositReportCODHeader,
						h.Customer_Id					AS IdCliente,
						h.Customer_Name					AS Cliente,
						h.Sender_Email					AS Correo,
						h.BankName						AS Banco,
						h.AccountNumber					AS Cuenta,
						h.AuthorizationNumber			AS NoDeposito,
						h.AuthorizationDate,
						h.Currency_Symbol				AS CurrencySymbol
					FROM dbo.DepositReportCODHeader h WITH (NOLOCK)
					WHERE h.Sender_Email = @SenderEmail
					AND h.Bank_Id = @IdBank
					AND h.AuthorizationDate >= @StarDate 
					AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				)
				-- =======================
				--		  HEADER
				-- =======================
				SELECT
					H.IdDepositReportCODHeader,
					H.IdCliente,
					H.Cliente,
					H.Correo,
					H.Banco,
					H.Cuenta,
					H.NoDeposito,
					FORMAT(H.AuthorizationDate,'dd/MM/yyyy hh:mm:ss tt') AS FechaPago,
					H.AuthorizationDate,
					CONVERT(VARCHAR(10), @StarDate, 103) + ' - ' + CONVERT(VARCHAR(10), @EndDate, 103) AS DateDelivery,
					H.CurrencySymbol
				FROM H
				ORDER BY H.AuthorizationDate ASC;
			END
			IF (@ResultSet = 2 OR @ResultSet = -1)
			BEGIN
				-- =======================
				--		   DETAIL
				-- =======================
				SELECT
					d.IdDepositReportCODHeader,
					CONCAT(d.GuideSerie, d.GuideNumber)								AS GuideNumber,
					ISNULL(d.Pieces_Dry,0) + ISNULL(d.Pieces_Cold,0)				AS Piezas,
					d.TotalWeight													AS Peso,
					d.Department_Name												AS Departamento,
					d.Township_Name													AS Municipio,
					CONCAT(d.Receiver_FirstName,' ',d.Receiver_LastName)			AS Receiver,
					FORMAT(d.ArrivalDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaArribo,
					FORMAT(d.DeliveryDate,'dd/MM/yyyy hh:mm:ss tt')					AS FechaEntrega,
					d.ArrivalDate,
					d.DeliveryDate,
					d.Collect_OnDelivery											AS CODAmount,
					IIF(d.TypeService = 'EXP','NDD',ISNULL(d.TypeService,'NDD'))	AS TypeService,
					CASE
						WHEN d.IsCollect = 1 THEN 'Collect'
						WHEN ISNULL(d.ConditionOfPaymentID,0) > 1 THEN 'Crédito'
						ELSE 'Prepago'
					END																AS TipodePago,
					d.PriceShippment												AS ShippmentAmount,
					d.Commission													AS CommissionAmount,
					d.CODCommissionPercentage										AS PorcentajeComision,
					d.Amount + ISNULL(d.Commission,0)								AS ChargedAmount,
					d.Amount														AS TotalAmount,
					IIF(h.Bank_Id IN (3,5,31,33,1),1,0)								AS FlagImmediateOrAch,
					h.AuthorizationDate,
					DATEDIFF(DAY, d.ArrivalDate, d.DeliveryDate)					AS DiasEntrega,
					DATEDIFF(DAY, d.DeliveryDate, h.AuthorizationDate)				AS DiasPago
				FROM dbo.ProcessedGuideCODNotifications d WITH (NOLOCK)
				INNER JOIN dbo.DepositReportCODHeader h WITH (NOLOCK)
					ON h.IdDepositReportCODHeader = d.IdDepositReportCODHeader
				WHERE h.Sender_Email = @SenderEmail
				AND h.Bank_Id = @IdBank
				AND h.AuthorizationDate >= @StarDate 
				AND h.AuthorizationDate < DATEADD(DAY, 1, @EndDate)
				ORDER BY h.AuthorizationDate ASC, d.IdDepositReportCODHeader, d.GuideSerie, d.GuideNumber;
			END
		END

	END
	
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;

END;