-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-19>
-- Description:	<Método para cargar datos de montos COD para uso de clientes individuales>
-- =============================================
CREATE PROCEDURE [dbo].[IndividualCustomerCODAmountsData]
@IdAccount INT = -1,
@StarDate DATETIME=NULL,
@EndDate DATETIME=NULL	

AS
BEGIN
	
	DECLARE @IdCustomer AS INT = (SELECT TOP 1 IdCustomer FROM dbo.Account WHERE AccIdAccount = @IdAccount)
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
		  ,s1.ShippmentAmount
		  ,s1.PorcentajeComision
		  ,s1.CommissionAmount
		  ,s1.TotalAmount
		FROM (SELECT
				cu.[IdCustomer] IdCliente
			   ,do.Sender_FirstName Cliente
			   ,btd.BankName Banco
			   ,btd.AccountNumber Cuenta
			   ,CONCAT(btd.[GuideSerie], btd.[GuideNumber]) GuideNumber
			   ,(do.Pieces_Dry + do.Pieces_Cold) Piezas
			   ,(SELECT
						SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
					FROM dbo.DeliveryOrderPiece dp
					WHERE dp.GuideSerie = do.Guide_Serie
					AND dp.GuideNumber = do.Guide_Number)
				Peso
			   ,ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento
			   ,ISNULL(twn.TownshipName, tw.TownshipName) Municipio
			   ,CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver
			   ,FORMAT((SELECT TOP 1
						dt.DateCreated
					FROM dbo.DeliveryOrderDetail dt
					WHERE dt.Guide_Serie = do.Guide_Serie
					AND dt.Guide_Number = do.Guide_Number
					AND dt.StatusOrderId IN (11, 2))
				,
				'dd/MM/yyyy hh:mm:ss tt'
				) FechaArribo
			   ,FORMAT((SELECT TOP 1
						dt.DateCreated
					FROM dbo.DeliveryOrderDetail dt
					WHERE dt.Guide_Serie = do.Guide_Serie
					AND dt.Guide_Number = do.Guide_Number
					AND dt.StatusOrderId = 5)
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
			   ,btd.[Commission] AS CommissionAmount
			   ,btd.CODCommissionPercentage AS PorcentajeComision
			   ,btd.[Amount] + btd.[Commission] AS ChargedAmount
			   ,btd.[Amount] AS TotalAmount
			   ,IIF(btd.BankId IN (3, 5, 31, 33, 1), 1, 0) FlagImmediateOrAch
			   ,btd.[AuthorizationDate]
			FROM [dbo].[BatchDetailCOD] AS btd
			INNER JOIN [dbo].[ProcessedGuideCOD] AS pg
				ON btd.[GuideSerie] = pg.[GuideSerie]
				AND btd.[GuideNumber] = pg.[GuideNumber]
			INNER JOIN [dbo].[DeliveryOrder] AS do
				ON btd.[GuideSerie] = do.[Guide_Serie]
				AND btd.[GuideNumber] = do.[Guide_Number]
			LEFT JOIN dbo.Township twn
				ON twn.IdTownship = do.ReceiverIdTownship
			LEFT JOIN dbo.Township tw
				ON tw.TownshipName = do.Receiver_Town
			LEFT JOIN dbo.Province prv
				ON prv.IdProvince = twn.IdProvince
			LEFT JOIN dbo.Province pr
				ON pr.IdProvince = tw.IdProvince
			LEFT JOIN dbo.VisitPointClient vpc
				ON vpc.CodeOfReference = do.Sender_ID
			LEFT JOIN dbo.Customer cu
				ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
			LEFT JOIN dbo.DeliveryCustomerBankAccount dc
				ON dc.DCBA_ID = do.DCBA_ID
			LEFT JOIN dbo.DeliveryBank bk
				ON bk.Id_bank = dc.DCBA_Bank_Id
			WHERE btd.[AuthorizationNumber] IS NOT NULL
			AND pg.BatchCODId IS NOT NULL
			AND (cu.IdCustomer = @IdCustomer)
            AND CAST(BTD.AuthorizationDate AS DATE)
            BETWEEN CAST(@StarDate AS DATE) AND CAST(@EndDate AS DATE)


		) s1
		ORDER BY s1.[AuthorizationDate] ASC;
	END
	ELSE
	BEGIN

			  SELECT		
				   s1.GuideNumber
				  ,s1.Receiver
				  ,s1.FechaEntrega
				  ,s1.FechaPago
				  ,s1.NoDeposito
				  ,s1.CODAmount
				  ,s1.ShippmentAmount
				  ,s1.PorcentajeComision
				  ,s1.CommissionAmount
				  ,s1.TotalAmount
				FROM (SELECT
						cu.[IdCustomer] IdCliente
					   ,do.Sender_FirstName Cliente
					   ,btd.BankName Banco
					   ,btd.AccountNumber Cuenta
					   ,CONCAT(btd.[GuideSerie], btd.[GuideNumber]) GuideNumber
					   ,(do.Pieces_Dry + do.Pieces_Cold) Piezas
					   ,(SELECT
								SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
							FROM dbo.DeliveryOrderPiece dp
							WHERE dp.GuideSerie = do.Guide_Serie
							AND dp.GuideNumber = do.Guide_Number)
						Peso
					   ,ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento
					   ,ISNULL(twn.TownshipName, tw.TownshipName) Municipio
					   ,CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver
					   ,FORMAT((SELECT TOP 1
								dt.DateCreated
							FROM dbo.DeliveryOrderDetail dt
							WHERE dt.Guide_Serie = do.Guide_Serie
							AND dt.Guide_Number = do.Guide_Number
							AND dt.StatusOrderId IN (11, 2)),
						'dd/MM/yyyy hh:mm:ss tt'
						) FechaArribo
					   ,FORMAT((SELECT TOP 1
								dt.DateCreated
							FROM dbo.DeliveryOrderDetail dt
							WHERE dt.Guide_Serie = do.Guide_Serie
							AND dt.Guide_Number = do.Guide_Number
							AND dt.StatusOrderId = 5),
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
					   ,btd.[Commission] AS CommissionAmount
					   ,btd.CODCommissionPercentage AS PorcentajeComision
					   ,btd.[Amount] + btd.[Commission] AS ChargedAmount
					   ,btd.[Amount] AS TotalAmount
					   ,IIF(btd.BankId IN (3, 5, 31, 33, 1), 1, 0) FlagImmediateOrAch
					   ,btd.[AuthorizationDate]
					FROM [dbo].[BatchDetailCOD] AS btd
					INNER JOIN [dbo].[ProcessedGuideCOD] AS pg
						ON btd.[GuideSerie] = pg.[GuideSerie]
						AND btd.[GuideNumber] = pg.[GuideNumber]
					INNER JOIN [dbo].[DeliveryOrder] AS do
						ON btd.[GuideSerie] = do.[Guide_Serie]
						AND btd.[GuideNumber] = do.[Guide_Number]
					LEFT JOIN dbo.Township twn
						ON twn.IdTownship = do.ReceiverIdTownship
					LEFT JOIN dbo.Township tw
						ON tw.TownshipName = do.Receiver_Town
					LEFT JOIN dbo.Province prv
						ON prv.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Province pr
						ON pr.IdProvince = tw.IdProvince
					LEFT JOIN dbo.VisitPointClient vpc
						ON vpc.CodeOfReference = do.Sender_ID
					LEFT JOIN dbo.Customer cu
						ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
					LEFT JOIN dbo.DeliveryCustomerBankAccount dc
						ON dc.DCBA_ID = do.DCBA_ID
					LEFT JOIN dbo.DeliveryBank bk
						ON bk.Id_bank = dc.DCBA_Bank_Id
					WHERE 
					btd.[AuthorizationNumber] IS NOT NULL
					AND pg.BatchCODId IS NOT NULL
					AND (cu.IdCustomer = @IdCustomer)
					AND CAST(BTD.AuthorizationDate AS DATE)
					BETWEEN CAST(@StarDate AS DATE) AND CAST(@EndDate AS DATE)


				) s1
				ORDER BY s1.[AuthorizationDate] ASC;




	END
END