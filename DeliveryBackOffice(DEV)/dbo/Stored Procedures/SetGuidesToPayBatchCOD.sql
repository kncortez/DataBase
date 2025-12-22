-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<Set datos lote COD>
-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Create date: <2024-12-19>
-- Description:	<Se agregaron validaciones para COD Pagado en COD Anticipado>
-- =============================================
-- Author:		<Oscar, Rodriguez>
-- Create date: <2024-12-12>
-- Description:	<Se agrego actualizacion de estado PAGADO para guias COD Anticipado>
-- =============================================
-- Author:		<Oscar, Rodriguez>
-- Create date: <2024-03-17>
-- Description:	<Se agrego optimizacion en base a indicaciones del DBA para la optimizacion del proceso de generacion de lotes COD>
-- =============================================
CREATE PROCEDURE [dbo].[SetGuidesToPayBatchCOD]
-- Add the parameters for the stored procedure here
	@BatchCODId INT,
	@TotalAmount DECIMAL(18,2),
	@AuthorizationNumber nvarchar(50),
	@AuthorizationDate datetime,
	@TokenCreated nvarchar(50),
	@Valid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	
	DECLARE @ValidateOperation INT = 0 -- control transacción
	DECLARE @Times INT = 0-- cantidad de veces que aparece el registro

	BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @StatusOrderAnticipatedCOD INT = (SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'COD Pagado Anticipado')
		IF @Valid = 0
			SET @Times = (
				SELECT COUNT(1)
				FROM [dbo].[BatchDetailCOD]
				WHERE [AuthorizationNumber] = @AuthorizationNumber
			)

		IF @Times = 0
		BEGIN
			UPDATE [dbo].[BatchCOD] 
			SET [TotalAmountIncluded] = @TotalAmount
			WHERE [IdBatchCOD] = @BatchCODId;

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

			UPDATE [dbo].[BatchDetailCOD]
			SET [AuthorizationNumber] = @AuthorizationNumber,
				[AuthorizationDate] = @AuthorizationDate,
				[CreditDate] = CONVERT(DATE,@AuthorizationDate)
			WHERE [BatchCODId] = @BatchCODId AND [Excluded] = 0;

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

			UPDATE dop
			SET dop.[IdStatus] = 0,
				dop.[TokenUpdate] = @TokenCreated,
				dop.[DateUpdate] = GETDATE()
			FROM [dbo].[DeliveryOrderPaid] dop WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.BatchDetailCOD bdc WITH(NOLOCK) 
			    ON bdc.GuideSerie = dop.Guide_Serie 
				AND bdc.GuideNumber = dop.Guide_Number
			WHERE bdc.BatchCODId = @BatchCODId
			AND bdc.Excluded = 0;

			IF ((SELECT IsAnticipatedCOD FROM DeliveryBackOffice.dbo.BatchCOD WHERE IdBatchCOD = @BatchCODId) = 1)
			BEGIN

				-- Inserta el estado "COD Pagado Anticipado" en tabla DeliveryOrderDetail.
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				  (
				  Guide_Serie,
				  Guide_number,
				  StatusOrderId,
				  UserCreated,
				  DateCreated
				  )
				SELECT GuideSerie,GuideNumber,@StatusOrderAnticipatedCOD, @TokenCreated,GETDATE() FROM [dbo].[BatchDetailCOD] 
				WHERE [BatchCODId] = @BatchCODId AND Excluded=0 AND CatConceptCODId =2

				UPDATE ACD
				SET ACD.BalanceStatus = 'PAGADO',
					DateUpdated = GETDATE(),
					TokenUpdated = @TokenCreated
				FROM DeliveryBackOffice.dbo.AnticipatedCODDetail ACD
				INNER JOIN [dbo].[BatchDetailCOD] BDC
				    ON BDC.GuideSerie = ACD.GuideSerie AND BDC.GuideNumber = ACD.GuideNumber
				WHERE BDC.[BatchCODId] = @BatchCODId
						
                DECLARE @TempData TblAnticipatedCODCustomerBalance;

				INSERT INTO @TempData
				(
					CustomerId,
					PortfolioId
				)
				SELECT DISTINCT ach.CustomerId, ach.PortfolioId
				FROM DeliveryBackOffice.dbo.AnticipatedCODDetail acd WITH(NOLOCK)
				INNER JOIN [dbo].[BatchDetailCOD] BDC WITH(NOLOCK) 
				    ON BDC.GuideSerie = ACD.GuideSerie AND BDC.GuideNumber = ACD.GuideNumber
				INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK) 
					ON ach.IdAnticipatedCODHeader = acd.AnticipatedCODHeaderId
				WHERE BDC.[BatchCODId] = @BatchCODId

				EXEC spUpdateBalanceByIdClient @TempData

                DELETE 
                    FROM @TempData
			END
			ELSE
			BEGIN
				-- Cambia el estado de la guia en tabla DeliveryOrder a 25 "COD Pagado".
				UPDATE [dbo].[DeliveryOrder]
				SET StatusOrderId = 25
				WHERE [Guide_Number] IN 
				(SELECT GuideNumber FROM [dbo].[BatchDetailCOD] 
				WHERE [BatchCODId] = @BatchCODId AND Excluded=0 AND CatConceptCODId =2) --OR, Se comento por proyecto COD Anticipado

				-- Inserta el estado 25 "COD Pagado" en tabla DeliveryOrderDetail.
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				  (
				  Guide_Serie,
				  Guide_number,
				  StatusOrderId,
				  UserCreated,
				  DateCreated
				  )
				SELECT GuideSerie,GuideNumber,25, @TokenCreated,GETDATE() FROM [dbo].[BatchDetailCOD] 
				WHERE [BatchCODId] = @BatchCODId AND Excluded=0 AND CatConceptCODId =2
				
DROP TABLE IF EXISTS #TempData;
IF @AuthorizationNumber IS NOT NULL AND @BatchCODId IS NOT NULL
BEGIN
;WITH Base AS
(
    SELECT
        btd.GuideSerie,
        btd.GuideNumber,
        btd.BankName,
        btd.AccountNumber,
        btd.BankId,
        @AuthorizationDate AS AuthorizationDate,
        @AuthorizationNumber AS AuthorizationNumber,
        btd.Commission,
        btd.CODCommissionPercentage,
        btd.Amount,
        do.Pieces_Dry,
        do.Pieces_Cold,
        do.Receiver_FirstName,
        do.Receiver_LastName,
        do.ReceiverIdTownship,
        do.Receiver_Town,
        do.Collect_OnDelivery,
        do.TypeService,
        do.IsCollect,
        cu.ConditionOfPaymentID,
        do.PriceShippment,
        do.Sender_Mail,
        cu.IdCustomer,
        COALESCE(cu.[Name], do.Sender_FirstName) AS ClienteNombre,
        cu.CODContactEmail,
        cu.RegexEmail,
        twn.TownshipName   AS TownshipNameTwn,
        prv.ProvinceName   AS ProvinceNameTwn,
        tw.TownshipName    AS TownshipNameTw,
        pr.ProvinceName    AS ProvinceNameTw,
		COALESCE(
		NULLIF(TRIM(cu.CODContactEmail), ''),
		NULLIF(TRIM(do.Sender_Mail),     ''),
		NULLIF(TRIM(cu.RegexEmail),      '')
		) HRegexEmail,
        CASE
		WHEN ISNULL(do.SenderCountryId, 'GT') = 'GT' THEN
		'Q.'
		ELSE
		'L.'
		END    AS CurrencySymbol,
		cu.IdCustomerType,
		do.Sender_ID,
		do.SalePipeLineId,
		vpc.IdKindOfVPClient,
		vpc.SaleChannelId,
		btd.IdCountry
    FROM dbo.BatchDetailCOD              AS btd WITH (NOLOCK)
    INNER JOIN dbo.ProcessedGuideCOD     AS pg  WITH (NOLOCK)
        ON  btd.GuideSerie  = pg.GuideSerie
        AND btd.GuideNumber = pg.GuideNumber
    INNER JOIN dbo.DeliveryOrder         AS do  WITH (NOLOCK)
        ON  btd.GuideSerie  = do.Guide_Serie
        AND btd.GuideNumber = do.Guide_Number
    LEFT JOIN dbo.Township               AS twn WITH (NOLOCK)
        ON twn.IdTownship = do.ReceiverIdTownship
    OUTER APPLY
    (
        SELECT TOP 1
               tw.IdProvince,
               tw.TownshipName
        FROM dbo.Township  AS tw WITH (NOLOCK)
        INNER JOIN dbo.Province AS PR WITH (NOLOCK)
            ON PR.IdProvince = tw.IdProvince
        WHERE tw.TownshipName = do.Receiver_Town
          AND PR.IdCountry    = do.ReceiverCountryId
    ) AS tw
    LEFT JOIN dbo.Province               AS prv WITH (NOLOCK)
        ON prv.IdProvince = twn.IdProvince
    LEFT JOIN dbo.Province               AS pr  WITH (NOLOCK)
        ON pr.IdProvince  = tw.IdProvince
    LEFT JOIN dbo.VisitPointClient       AS vpc WITH (NOLOCK)
        ON vpc.CodeOfReference = do.Sender_ID
    LEFT JOIN dbo.Customer               AS cu  WITH (NOLOCK)
        ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
    LEFT JOIN dbo.DeliveryCustomerBankAccount AS dc  WITH (NOLOCK)
        ON dc.DCBA_Id = do.DCBA_ID
    LEFT JOIN dbo.DeliveryBank           AS bk  WITH (NOLOCK)
        ON bk.Id_bank = dc.DCBA_Bank_Id
    WHERE btd.BatchCODId = @BatchCODId and btd.Excluded = 0
),
Pieces AS
(
    SELECT
        dp.GuideSerie,
        dp.GuideNumber,
        SUM(ISNULL(dp.MassWeight, dp.PieceWeight)) AS Peso
    FROM dbo.DeliveryOrderPiece dp WITH (NOLOCK)
    INNER JOIN Base b
        ON  b.GuideSerie  = dp.GuideSerie
        AND b.GuideNumber = dp.GuideNumber
    GROUP BY dp.GuideSerie, dp.GuideNumber
),
Dates AS
(
    SELECT
        b.GuideSerie,
        b.GuideNumber,
        MIN(CASE WHEN dt.StatusOrderId IN (11, 2) THEN dt.DateCreated END) AS FechaArriboDate,
        MIN(CASE WHEN dt.StatusOrderId = 5 THEN dt.DateCreated END)       AS FechaEntregaDate
    FROM Base b
    INNER JOIN dbo.DeliveryOrderDetail dt WITH (NOLOCK)
        ON  dt.Guide_Serie  = b.GuideSerie
        AND dt.Guide_Number = b.GuideNumber
    GROUP BY b.GuideSerie, b.GuideNumber
),
Final AS
(
    SELECT
        b.IdCustomer                                        AS IdCliente,
        b.ClienteNombre                                     AS ClienteCorporativo,
        COALESCE(
            b.CODContactEmail,
            REPLACE(REPLACE(b.RegexEmail, '^', ''), '$', '')
        )                                                   AS CorreoCliente,
        b.Sender_Mail                                       AS CorreoSender,
		b.HRegexEmail,
        b.BankName                                          AS Banco,
		b.BankId,
        b.AccountNumber                                     AS Cuenta,
        CONCAT(b.GuideSerie, b.GuideNumber)                 AS GuideNumber,
        (b.Pieces_Dry + b.Pieces_Cold)                      AS Piezas,
        p.Peso,
        ISNULL(b.ProvinceNameTwn, b.ProvinceNameTw)         AS Departamento,
        ISNULL(b.TownshipNameTwn, b.TownshipNameTw)         AS Municipio,
        CONCAT(b.Receiver_FirstName, b.Receiver_LastName)   AS Receiver,
        FORMAT(d.FechaArriboDate,  'dd/MM/yyyy hh:mm:ss tt') AS FechaArribo,
        FORMAT(d.FechaEntregaDate, 'dd/MM/yyyy hh:mm:ss tt') AS FechaEntrega,
        FORMAT(b.AuthorizationDate,'dd/MM/yyyy hh:mm:ss tt') AS FechaPago,
        b.AuthorizationNumber                        AS NoDeposito,
        b.Collect_OnDelivery                                AS CODAmount,
        IIF(b.TypeService = 'EXP', 'NDD', ISNULL(b.TypeService, 'NDD'))
                                                            AS TypeService,
        IIF(
            b.IsCollect = 'true',
            'Collect',
            IIF(ISNULL(b.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago')
        )                                                   AS TipoDePago,
        b.PriceShippment                                    AS ShippmentAmount,
        b.Commission                                        AS CommissionAmount,
        b.CODCommissionPercentage                           AS PorcentajeComision,
        b.Amount + b.Commission                             AS ChargedAmount,
        b.Amount                                            AS TotalAmount,
        IIF(b.BankId IN (3, 5, 31, 33, 1), 1, 0)            AS FlagImmediateOrAch,
        b.AuthorizationDate,
        b.CurrencySymbol,
		b.IsCollect,
		b.Receiver_FirstName,
		b.Receiver_LastName,
		b.Pieces_Dry,
		b.Pieces_Cold,
		b.GuideSerie,
		b.GuideNumber as BGuideNumber,
		b.IdCustomerType,
		b.ConditionOfPaymentID,
		b.Sender_ID,
		b.ReceiverIdTownship,
		b.Receiver_Town,
		b.PriceShippment,
		b.SalePipeLineId,
		b.IdKindOfVPClient,
		b.SaleChannelId,
		b.IdCountry
    FROM Base   b
    LEFT JOIN Pieces p
        ON p.GuideSerie  = b.GuideSerie
       AND p.GuideNumber = b.GuideNumber
    LEFT JOIN Dates  d
        ON d.GuideSerie  = b.GuideSerie
       AND d.GuideNumber = b.GuideNumber
)

SELECT
    f.*,
    ISNULL(
        DATEDIFF(DAY, CONVERT(DATE, f.FechaArribo,103),  CONVERT(DATE, f.FechaEntrega,103)),
        0
    ) AS DiasEntrega,
    ISNULL(
        DATEDIFF(DAY, CONVERT(DATE, f.FechaEntrega,103), CONVERT(DATE, f.FechaPago,103)),
        0
    ) AS DiasPago
into #TempData
FROM Final f
ORDER BY f.AuthorizationDate ASC;

DROP TABLE IF EXISTS #HeaderMapping;

CREATE TABLE #HeaderMapping
(
    IdDepositReportCODHeader BIGINT,
    Customer_Id INT
);
;WITH HeaderSource AS
(
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY AuthorizationDate DESC) AS rn
    FROM #TempData
)
INSERT INTO dbo.DepositReportCODHeader
(
    Batch_COD_Id,
    Customer_Id,
    Customer_Name,
    Customer_Email,
    Sender_Email,
    Bank_Id,
    BankName,
    AccountNumber,
    Currency_Symbol,
    Country_Id,
	SalePipeLineId,
    IdKindOfVPClient,
    SaleChannelId,
	Customer_Type,
    AuthorizationNumber,
    AuthorizationDate,
	Notificated,
    RowStatus,
    TokenCreated,
    DateCreated
)
OUTPUT inserted.IdDepositReportCODHeader, inserted.Customer_Id
INTO #HeaderMapping(IdDepositReportCODHeader, Customer_Id)
SELECT 
    @BatchCODId,
    IdCliente,
    ClienteCorporativo,
    HRegexEmail,
    CorreoSender,
    BankId,
    Banco,
    Cuenta,
    CurrencySymbol,
    IdCountry,
    SalePipeLineId,
    IdKindOfVPClient,
    SaleChannelId,
	IdCustomerType,
    NoDeposito,
    AuthorizationDate,
	0,
    1,
    @TokenCreated,
    GETDATE()
FROM HeaderSource
WHERE rn = 1;

INSERT INTO dbo.ProcessedGuideCODNotifications
(
    IdDepositReportCODHeader,
    GuideSerie,
    GuideNumber,
    IdCustomerType,
    ConditionOfPaymentID,
    Pieces_Dry,
    Pieces_Cold,
    TotalWeight,
    Department_Name,
    Township_Name,
    ArrivalDate,
    DeliveryDate,
    Sender_ID,
    ReceiverIdTownship,
    Receiver_FirstName,
    Receiver_LastName,
    Receiver_Town,
    Collect_OnDelivery,
    TypeService,
    IsCollect,
    PriceShippment,
    Commission,
    CODCommissionPercentage,
    Amount,
    Country_Id,
    RowStatus,
    TokenCreated,
    DateCreated
)
SELECT 
    hm.IdDepositReportCODHeader,
    f.GuideSerie,
    f.BGuideNumber,
    f.IdCustomerType,
    f.ConditionOfPaymentID,
    f.Pieces_Dry,
    f.Pieces_Cold,
    f.Peso,
    f.Departamento,
    f.Municipio,
    CONVERT(DATETIME, f.FechaArribo, 103),
    CONVERT(DATETIME, f.FechaEntrega, 103),
    f.Sender_ID,
    f.ReceiverIdTownship,
    f.Receiver_FirstName,
    f.Receiver_LastName,
    f.Receiver_Town,
    f.CODAmount,
    f.TypeService,
    f.IsCollect,
    f.PriceShippment,
    f.CommissionAmount,
    f.PorcentajeComision,
    f.TotalAmount,
    f.IdCountry,
    1,
    @TokenCreated,
    GETDATE()
FROM #TempData f
INNER JOIN #HeaderMapping hm
    ON hm.Customer_Id = f.IdCliente;
END
			END
		
		-----------------WEBHOOK.INI-----------------------		
		DECLARE @WebhookCustomerTable AS TABLE(
			CustomerId INT,
			CustomerEndpointId BIGINT,
			WebhookType INT,
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			GuideStatusId TINYINT
		)
		BEGIN TRY
			DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' AND WT.RowStatus = 1);

			-- Clientes de las guías por procesar
			INSERT INTO 
				@WebhookCustomerTable
				(CustomerId, GuideSerie, GuideNumber, GuideStatusId)
			SELECT
				DISTINCT
					DO.IdCustomer,
					BDCOD.GuideSerie,
					BDCOD.GuideNumber,
					DO.StatusOrderId
			FROM
				[DeliveryBackOffice].[dbo].[BatchDetailCOD] BDCOD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON
						BDCOD.GuideSerie = DO.Guide_Serie
						AND
						BDCOD.GuideNumber = DO.Guide_Number
			WHERE
				BDCOD.BatchCODId = @BatchCODId 
				AND 
				Excluded = 0 
				AND 
				CatConceptCODId = 2;

			-- Ingresar endpoints de cliente
			UPDATE
				@WebhookCustomerTable
			SET
				CustomerEndpointId = WE.IdWebhookEndpoint
				,WebhookType = @GuideStatusChangeWebhook
			FROM
				[DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
				INNER JOIN
					@WebhookCustomerTable WCT
					ON
						WE.CustomerId = WCT.CustomerId
			WHERE
				WE.WebhookTypeId = @GuideStatusChangeWebhook;

			DECLARE @ResponseTable AS TABLE (
				InsertedId BIGINT
			);

			INSERT INTO 
				[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
				(
					[GuideSerie]
					,[GuideNumber]
					,[CustomerId]
					,[StatusOrderId]
					,[WebhookEndpointId]
					,[HasNotified]
					,[TokenCreated]
					,[DateCreated]
				)
			OUTPUT inserted.IdWebhookTrackingQueue INTO @ResponseTable (InsertedId)
			SELECT
				WCT.GuideSerie
				,WCT.GuideNumber
				,WCT.CustomerId
				,WCT.GuideStatusId
				,WCT.CustomerEndpointId
				,0
				,@TokenCreated
				,GETDATE()
			FROM
				@WebhookCustomerTable WCT
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK)
					ON
						WCT.CustomerId = WRBU.CustomerId
						AND
						WCT.GuideStatusId = WRBU.StatusOrderId
						AND
						WCT.WebhookType = WRBU.WebhookTypeId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK)
					ON
						WCT.GuideSerie = WTQ.GuideSerie
						AND
						WCT.GuideNumber = WTQ.GuideNumber
						AND
						WCT.GuideStatusId = WTQ.StatusOrderId
						AND 
						WTQ.RowStatus = 1
			WHERE
				WRBU.IdWebhookRestrinctionByUser IS NOT NULL
				AND
				WTQ.IdWebhookTrackingQueue IS NULL

		END TRY
		BEGIN CATCH

		END CATCH
		-------------------WEBHOOK.FIN------------------------------	

			--------------------------------------------------------------------------------

			INSERT INTO [dbo].[DeliveryOrderPaid]
					([Guide_Serie]
					,[Guide_Number]
					,[Deposit_Number]
					,[IsVirtualDeposit]
					,[IdStatus]
					,[TokenCreated]
					,[DateCreated]
					,[TokenUpdate]
					,[DateUpdate]
					,[IdDeliveryOrderPaidHeader]
					,[DocumentType])
				SELECT bd.[GuideSerie]
					,bd.[GuideNumber]
					,@AuthorizationNumber
					,1
					,1
					,@TokenCreated
					,@AuthorizationDate
					,NULL
					,NULL
					,NULL
					,NULL
				FROM [dbo].[BatchDetailCOD] AS bd
				WHERE bd.[BatchCODId] = @BatchCODId AND bd.[Excluded] = 0;

				IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

				UPDATE do
				SET do.[Deposit_Number] = @AuthorizationNumber
				,do.[Guide_Collected] = 1
				FROM [dbo].[DeliveryOrder] AS do
				INNER JOIN [dbo].[BatchDetailCOD] AS bd 
				ON do.[Guide_Serie] = bd.[GuideSerie] 
				AND do.[Guide_Number] = bd.[GuideNumber]
				WHERE bd.[BatchCODId] = @BatchCODId AND bd.[Excluded] = 0;
				
				IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1
		END
		ELSE
			SET @ValidateOperation = -1 --Registro ya existe
	END TRY
	BEGIN CATCH
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
		IF(@ValidateOperation = 4)
		BEGIN 
			SELECT			  
				1 AS 'StatusCode',
				'Registros guardados correctamente' AS 'Description', 
				@ValidateOperation AS 'NumTransferID'
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			IF(@ValidateOperation = -1)
			BEGIN
				SELECT 
					0 AS 'StatusCode',
					'El registro ya existe' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE
			BEGIN
				SELECT 
					-1 AS 'StatusCode',
					'Error al actualizar registros' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			
			ROLLBACK TRANSACTION
		END
	END


	 SET NOCOUNT OFF
END