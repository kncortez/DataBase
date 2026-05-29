-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-19>
-- Description:	<Método para cargar datos de montos COD para uso de clientes individuales>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-07-23>
-- Description:	<Se agrego moneda para COD y Shippment>
-- =============================================
CREATE PROCEDURE [dbo].[IndividualCustomerCODAmountsData]
@IdAccount INT = -1,
@StarDate DATETIME=NULL,
@EndDate DATETIME=NULL	

AS
BEGIN
	
	DECLARE @IdCustomer AS INT = (SELECT TOP 1 IdCustomer 
	    FROM dbo.Account WITH(NOLOCK) WHERE AccIdAccount = @IdAccount) --HOTFIX 13/11/2024 no tenía with(nolock)
        SET @EndDate  = Format(GETDATE(),'yyyy-MM-dd');
	
	SET NOCOUNT ON;

	IF (@StarDate IS NULL)
	BEGIN
		SET @StarDate  = Format(GETDATE()-7,'yyyy-MM-dd');
		SET @EndDate   = Format(GETDATE(),'yyyy-MM-dd');
	END
	
	IF((SELECT DATEDIFF(DAY,@StarDate,@EndDate))>30) /* Validar que el rango no sea mayor a 30 días  */
	BEGIN

		SET @StarDate   = Format(GETDATE()-30,'yyyy-MM-dd');
		SET @EndDate    = Format(GETDATE(),'yyyy-MM-dd');


    SELECT		
		   s1.GuideNumber
		  ,s1.Receiver
		  ,s1.FechaEntrega
		  ,s1.FechaPago
		  ,s1.NoDeposito
		  ,s1.CODAmount
		  ,s1.CODCurrency
		  ,s1.ShippmentAmount
		  ,s1.ShippmentCurrency
		  ,s1.PorcentajeComision
		  ,s1.CommissionAmount
		  ,s1.TotalAmount
		FROM (SELECT DISTINCT
				cu.[IdCustomer] IdCliente
			   ,do.Sender_FirstName Cliente
			   ,btd.BankName Banco
			   ,btd.AccountNumber Cuenta
			   ,CONCAT(do.[Guide_Serie], do.[Guide_Number]) GuideNumber
			   ,(SELECT DISTINCT
						SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
					FROM dbo.DeliveryOrderPiece dp WITH(NOLOCK) --HOTFIX 13/11/2024 no tenía with(nolock)
					WHERE dp.GuideSerie = do.Guide_Serie
					AND dp.GuideNumber = do.Guide_Number)
				Peso
			   ,ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento
			   ,ISNULL(twn.TownshipName, tw.TownshipName) Municipio
			   ,CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver
			   ,FORMAT((SELECT TOP 1
						dt.DateCreated
					FROM dbo.DeliveryOrderDetail dt WITH(NOLOCK)
					WHERE dt.Guide_Serie = do.Guide_Serie
					AND dt.Guide_Number = do.Guide_Number
					AND dt.StatusOrderId  IN (5,22))
				,
				'dd/MM/yyyy hh:mm:ss tt'
				) FechaEntrega
			   ,FORMAT(btd.[AuthorizationDate], 'dd/MM/yyyy hh:mm:ss tt') FechaPago
			   ,btd.[AuthorizationNumber] NoDeposito
			   ,do.[Collect_OnDelivery] AS CODAmount
			   ,IIF(do.[TypeService] = 'EXP', 'NDD', ISNULL(do.[TypeService], 'NDD')) TypeService
			   ,IIF(do.IsCollect = 'true',
				'Collect',
				(IIF(ISNULL(cu.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago'))) TipodePago
			   ,do.[PriceShippment] AS ShippmentAmount
			   ,ISNULL(c1.Symbol,'Q') AS CODCurrency
			   ,ISNULL(c2.Symbol,'Q') AS ShippmentCurrency
			   ,btd.[Commission] AS CommissionAmount
			   ,btd.CODCommissionPercentage AS PorcentajeComision
			   ,btd.[Amount] + btd.[Commission] AS ChargedAmount
			   ,btd.[Amount] AS TotalAmount
			   ,btd.[AuthorizationDate]
			FROM [dbo].[DeliveryOrder] AS do WITH(NOLOCK)
			LEFT JOIN [dbo].[Cost] AS c WITH(NOLOCK)
				ON [do].[Guide_Serie] = [c].[GuideSerie] AND [do].[Guide_Number] = [c].[GuideNumber]
			LEFT JOIN [dbo].[CatCurrencyCOD] AS c1 WITH(NOLOCK)
				ON [c].[CodCurrency] = [c1].[IdCatCurrencyCOD]
			LEFT JOIN [dbo].[CatCurrencyCOD] AS c2 WITH(NOLOCK)
				ON [c].[ShippingCurrency] = [c2].[IdCatCurrencyCOD]
			LEFT JOIN [dbo].[BatchDetailCOD] AS btd WITH(NOLOCK)
				ON btd.[GuideSerie] = do.[Guide_Serie]
				AND btd.[GuideNumber] = do.[Guide_Number]
				AND btd.CatConceptCODId = 2
			LEFT JOIN dbo.Township twn WITH(NOLOCK)
				ON twn.IdTownship = do.ReceiverIdTownship
			LEFT JOIN dbo.Township tw WITH(NOLOCK)
				ON tw.TownshipName = do.Receiver_Town
			LEFT JOIN dbo.Province prv WITH(NOLOCK)
				ON prv.IdProvince = twn.IdProvince
			LEFT JOIN dbo.Province pr WITH(NOLOCK) --HOTFIX 13/11/2024 no tenía with(nolock)
				ON pr.IdProvince = tw.IdProvince
			LEFT JOIN dbo.VisitPointClient vpc WITH(NOLOCK)
				ON vpc.CodeOfReference = do.Sender_ID
			LEFT JOIN dbo.Customer cu WITH(NOLOCK)
				ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
			WHERE 
			ISNULL(DO.[Collect_OnDelivery], 0) > 0
			AND 
			cu.IdCustomer = @IdCustomer
            AND 
			CAST(do.DateCreated AS DATE) BETWEEN CAST(@StarDate AS DATE) AND CAST(@EndDate AS DATE)


		) s1
		ORDER BY s1.[AuthorizationDate] ASC;
	END
	ELSE
	BEGIN
	   PRINT 'HOLA'
		SELECT		
			s1.GuideNumber
			,s1.Receiver
			,s1.FechaEntrega
			,s1.FechaPago
			,s1.NoDeposito
			,s1.CODAmount
			,s1.CODCurrency
			,s1.ShippmentAmount
			,s1.ShippmentCurrency
			,s1.PorcentajeComision
			,s1.CommissionAmount
			,s1.TotalAmount
		FROM (SELECT DISTINCT
				cu.[IdCustomer] IdCliente
				,do.Sender_FirstName Cliente
				,btd.BankName Banco
				,btd.AccountNumber Cuenta
				,CONCAT(do.[Guide_Serie], do.[Guide_Number]) GuideNumber
				,(SELECT
						SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
					FROM dbo.DeliveryOrderPiece dp WITH(NOLOCK) --HOTFIX 13/11/2024 no tenía with(nolock)
					WHERE dp.GuideSerie = do.Guide_Serie
					AND dp.GuideNumber = do.Guide_Number)
				Peso
				,ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento
				,ISNULL(twn.TownshipName, tw.TownshipName) Municipio
				,CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver
				,FORMAT((SELECT TOP 1
						dt.DateCreated
					FROM dbo.DeliveryOrderDetail dt WITH(NOLOCK)
					WHERE dt.Guide_Serie = do.Guide_Serie
					AND dt.Guide_Number = do.Guide_Number
					AND dt.StatusOrderId IN (5,22)),
				'dd/MM/yyyy hh:mm:ss tt'
				) FechaEntrega
				,FORMAT(btd.[AuthorizationDate], 'dd/MM/yyyy hh:mm:ss tt') FechaPago
				,btd.[AuthorizationNumber] NoDeposito
				,do.[Collect_OnDelivery] AS CODAmount
				,IIF(do.[TypeService] = 'EXP', 'NDD', ISNULL(do.[TypeService], 'NDD')) TypeService
				,IIF(do.IsCollect = 'true',
				'Collect',
				(IIF(ISNULL(cu.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago'))) TipodePago
				,do.[PriceShippment] AS ShippmentAmount
				,ISNULL(c1.Symbol,'Q') AS CODCurrency
			    ,ISNULL(c2.Symbol,'Q') AS ShippmentCurrency
				,btd.[Commission] AS CommissionAmount
				,btd.CODCommissionPercentage AS PorcentajeComision
				,btd.[Amount] + btd.[Commission] AS ChargedAmount
				,btd.[Amount] AS TotalAmount
				,btd.[AuthorizationDate]
			FROM [dbo].[DeliveryOrder] AS do WITH(NOLOCK)
			LEFT JOIN [dbo].[Cost] AS c WITH(NOLOCK)
				ON [do].[Guide_Serie] = [c].[GuideSerie] AND [do].[Guide_Number] = [c].[GuideNumber]
			LEFT JOIN [dbo].[CatCurrencyCOD] AS c1 WITH(NOLOCK)
				ON [c].[CodCurrency] = [c1].[IdCatCurrencyCOD]
			LEFT JOIN [dbo].[CatCurrencyCOD] AS c2 WITH(NOLOCK)
				ON [c].[ShippingCurrency] = [c2].[IdCatCurrencyCOD]
			LEFT JOIN [dbo].[BatchDetailCOD] AS btd WITH(NOLOCK)
				ON btd.[GuideSerie] = do.[Guide_Serie]
				AND btd.[GuideNumber] = do.[Guide_Number]
				AND btd.CatConceptCODId = 2
			LEFT JOIN dbo.Township twn WITH(NOLOCK)
				ON twn.IdTownship = do.ReceiverIdTownship
			LEFT JOIN dbo.Township tw WITH(NOLOCK)
				ON tw.TownshipName = do.Receiver_Town
			LEFT JOIN dbo.Province prv WITH(NOLOCK)
				ON prv.IdProvince = twn.IdProvince
			LEFT JOIN dbo.Province pr WITH(NOLOCK)
				ON pr.IdProvince = tw.IdProvince
			LEFT JOIN dbo.VisitPointClient vpc WITH(NOLOCK)
				ON vpc.CodeOfReference = do.Sender_ID
			LEFT JOIN dbo.Customer cu WITH(NOLOCK)
				ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
			WHERE 
			ISNULL(DO.[Collect_OnDelivery], 0) > 0
			AND 
			cu.IdCustomer = @IdCustomer
			AND
			CAST(do.DateCreated AS DATE) BETWEEN CAST(@StarDate AS DATE) AND CAST(@EndDate AS DATE)


		) s1
		ORDER BY s1.[AuthorizationDate] ASC;

	END
END