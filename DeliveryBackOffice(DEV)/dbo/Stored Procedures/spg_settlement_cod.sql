-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-12-08>
-- Description:	<Recupera información para generar manifiesto de liquidación (COD)>
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2025-09-12>
-- Description:	<Se agrega sumatoria de los depositos de Efectibox en el monto total liquidado.>
-- =============================================
-- Author:		<Freddy, Camposeco>
-- Create date: <2025-10-17>
-- Description:	<>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_cod]
		@IdManifest INT
AS
BEGIN
	
	DECLARE @GuideCount INT
	DECLARE @AmountMoney DECIMAL(8,2) = 0;
	DECLARE @AmountDeposit DECIMAL(8,2) = 0;
	DECLARE @AmountTotal DECIMAL(8,2) = 0;
	DECLARE @TotalVouchers DECIMAL(19,4) = 0;

	SET NOCOUNT ON;

	SET @GuideCount = (
		SELECT 
			COUNT(dobs.Guides_Received_COD)
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd WITH(NOLOCK) 
			ON dsd.ID_DeliveryOrderBySettlement = dobs.ID 
		WHERE dobs.ID = @IdManifest
		AND dsd.Guide_Settlement = 1 -- guía liquidada en bodega
		AND dsd.Guide_Discharged = 1  -- guía liquidada vía COD
		AND dsd.RowStatus = 1
	)

	--Monto liquidado Billetes/monedas
	SET  @AmountMoney = (SELECT COALESCE(SUM(mdos.Quantity*cm.Value), 0) TotalAmountCount
						FROM MoneyByDeliveryOrderBySettlement mdos WITH(NOLOCK)
						INNER JOIN CatMoney cm WITH(NOLOCK)
							ON mdos.CatMoneyId = cm.IdCatMoney
						WHERE DeliveryOrderBySettlementId = @IdManifest);
	--Monto liquidado Depositos
	SET @AmountDeposit = (SELECT COALESCE(SUM(AmountApplied), 0) TotalAmountCount
						  FROM DeliveryBackOffice.dbo.RelDepositManifest WITH(NOLOCK)
						  WHERE DeliveryOrderBySettlementId = @IdManifest AND RowStatus = 1);
	--Monto Total
	SET @AmountTotal = @AmountMoney + @AmountDeposit;

	-- Calcular el total de vouchers Efectibox aplicados al manifiesto
	SET @TotalVouchers = (
		SELECT ISNULL(SUM(rdm.AmountApplied), 0)
		FROM DeliveryBackOffice.dbo.RelDepositManifest rdm WITH(NOLOCK)
		WHERE rdm.DeliveryOrderBySettlementId = @IdManifest
		  AND rdm.RowStatus = 1
	);

	SELECT 
			dobs.ID, 
			dobs.Date_Received_COD AS Date_Received, 
			--dobs.Pieces_Dry_Received, 
			--dobs.Pieces_Cold_Received, 
			@GuideCount AS Guides_Received,
			isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') AS Courier_Name,
			dobs.Route_Received_COD AS Route_Received,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username AS IdUser_Username_Received,
			COALESCE(@AmountTotal,0) AS Amount_Received,
			(SELECT Value
				FROM Contingency WITH(NOLOCK)
				WHERE DeliveryOrderBySettlementId = @IdManifest) Amount_Difference,
			cs.StationName Hub,
			@TotalVouchers as TotalVouchers  -- Nuevo campo: Total de vouchers aplicados
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK) 
			ON sr.ID = dobs.ID_Courier
		INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK) 
			ON lbt.SSN_IdToken = dobs.User_Received_COD
		LEFT JOIN CatStation cs WITH(NOLOCK)
			ON cs.IdStation = dobs.SettlementStationId  
		WHERE dobs.ID = @IdManifest

END
