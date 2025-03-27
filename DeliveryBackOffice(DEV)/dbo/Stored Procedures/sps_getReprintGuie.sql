-- =============================================
-- Modified:    <Daniel, Ramirez>
-- Create date: <2024-07-24>
-- Description: <Se ajusto la informacion de salida para que obtenga la moneda correcta>
-- =============================================
-- Modified:    <Daniel, Ramirez>
-- Create date: <2024-07-24>
-- Description: <Se retiro el parametro de pais, y se toma el pais desde la guia>
-- =============================================
CREATE PROCEDURE [dbo].[sps_getReprintGuie]
    @Guide_Number INT = 137916,
    @Serie_Number VARCHAR(2) = 'FD'
as
begin
    DECLARE @CountryThatConsults VARCHAR(2) = 'GT'

	DECLARE @Integration TABLE
	(
		Currency NVARCHAR(5),
		[Description] NVARCHAR(50),
		Price DECIMAL(8, 2)
	)

	DECLARE @Temp TABLE
	(
		[length] DECIMAL(8, 2),
		width DECIMAL(8, 2),
		height DECIMAL(8, 2),
		[weight] DECIMAL(8, 2),
		amount DECIMAL(8, 2),
		currency NVARCHAR(10),
		ParcelCode NVARCHAR(15),
		fragil NVARCHAR(10),
		descripcion NVARCHAR(100)
	)

    SET @CountryThatConsults = (
		SELECT TOP 1 SenderCountryId
			FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
		WHERE Guide_Number = @Guide_Number
			AND Guide_Serie = @Serie_Number
    );

	IF (@CountryThatConsults IS NULL OR @CountryThatConsults = '')
	BEGIN
		SET @CountryThatConsults = 'GT';
	END;

	declare @FranchiseVisitPointTypeId int = 
	(
		select 
			top (1) 
				[KOVPC].[IdKindOfVPClient] 
		from
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  with(nolock) 
		where
			[KOVPC].[KindOfVPName] = 'Concesionario' AND ISNULL([KOVPC].[IdCountry],'GT')=@CountryThatConsults 
	)
	declare @ExpressVisitPointTypeId int = 
	(
		select 
			top (1) 
				[KOVPC].[IdKindOfVPClient] 
		from
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  with(nolock) 
		where
			[KOVPC].[KindOfVPName] = 'Express Center' AND ISNULL([KOVPC].[IdCountry],'GT')=@CountryThatConsults 
	)
	declare @IndividualWebSys int =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web'  
	)
	DECLARE @ExpressWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-ExpressCenter' 
	)
	DECLARE @CorporateWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-Corporativo'  
	)
	DECLARE @ParserSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Parser'  
	)
	DECLARE @GuidePriority INT = 0;
    DECLARE @jsonOutput VARCHAR(MAX) = '',
            @parcels NVARCHAR(MAX) = N'',
            /*pieces*/
            @i INT = 0,
            @identity INT = 1,
            @arpieces VARCHAR(MAX) = '',
            @calcurrency VARCHAR(50) = '',
            @TotalWeight DECIMAL(12, 2),
            @TotalValue DECIMAL(12, 2);
    DECLARE @TMPPICES TABLE
    (
        it INT IDENTITY(1, 1),
        myrow INT
    );
    DECLARE @j INT = 0,
            @integrationCost VARCHAR(MAX) = '',
            @identityCost INT;
   DECLARE @StatusPackage INT = (SELECT IdCatSalesPackageStatus FROM CatSalesPackageStatus WHERE SalesPackageStatusName = 'Activa')

    SELECT 
		@i = COUNT(1),
		@TotalWeight = ISNULL(SUM(PieceWeight), 0),
		@TotalValue = ISNULL(SUM(Amount), 0)
    FROM 
		DeliveryBackOffice.[dbo].[DeliveryOrderPiece] WITH(NOLOCK)
    WHERE 
		GuideNumber = @Guide_Number
		AND
		GuideSerie = @Serie_Number;

    INSERT INTO @TMPPICES
    (
        myrow
    )
    SELECT GuidePiece
    FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece] WITH(NOLOCK)
    WHERE GuideNumber = @Guide_Number
	AND GuideSerie = @Serie_Number;

	DECLARE @EXCKindOfVPC INT =
	(
		SELECT 
			[KOVPC].[IdKindOfVPClient] 
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center'  
		AND ISNULL(IdCountry,'GT')=@CountryThatConsults
	);

    DECLARE @DaysToExpiration INT =
            (
                SELECT ISNULL(CAST(conf.Value AS INT), 45) DaysToExpiration
                FROM DeliveryBackOffice.dbo.ConfigParams conf WITH(NOLOCK)
                WHERE conf.Name = 'DaysToExpiration'
                      AND Status = 1
            );

    DECLARE @idCust BIGINT =
            (
                SELECT IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                WHERE Guide_Number = @Guide_Number
				AND Guide_Serie = @Serie_Number
            );
    DECLARE @customerType INT =
            (
                SELECT IdCustomerType
                FROM DeliveryBackOffice.dbo.Customer WITH (NOLOCK)
                WHERE IdCustomer = @idCust
            );
    DECLARE @SalesChannel BIGINT =
            (
                SELECT SalePipeLineId
                FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                WHERE Guide_Number = @Guide_Number
				AND Guide_Serie = @Serie_Number
            );
    DECLARE @Impersonate VARCHAR(20) = CASE
                                           WHEN @SalesChannel = 3
                                                AND
                                                (
                                                    @customerType = 1
                                                    OR @customerType = 3
                                                ) THEN
                                               'TRUE'
                                           ELSE
                                               'FALSE'
                                       END;
    DECLARE @ExpressName VARCHAR(50) = '';

	DECLARE @IDCatBusinessB2B INT = (SELECT IdBusinessSegment FROM DBO.CatBusinessSegment WHERE BusinessSegmentName='B2B'AND ISNULL(IdCountry,'GT')=@CountryThatConsults);

    IF (@Impersonate = 'TRUE')
    BEGIN
        SET @ExpressName =
        (
            SELECT IIF(vpc.CodeOfReference=0,'',DescriptionOfClient)
            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = do.OriginSenderId
            WHERE Guide_Number = @Guide_Number
			AND Guide_Serie = @Serie_Number
        );
    END;
    ELSE
    BEGIN
        IF (@SalesChannel = 3 OR @SalesChannel = 4)
        BEGIN
            SET @ExpressName =
            (
                SELECT DescriptionOfClient
                FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                        ON vpc.CodeOfReference = do.Sender_ID
                WHERE Guide_Number = @Guide_Number
				AND Guide_Serie = @Serie_Number
            );
        END;
    END;

    WHILE @i > 0
    BEGIN

		SET  @calcurrency = (SELECT TOP 1 COALESCE(Currency, '') FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece] WITH (NOLOCK) WHERE GuideNumber = @Guide_Number AND GuideSerie = @Serie_Number)
		INSERT INTO @Temp ([length], width, height, [weight], amount, currency, ParcelCode, fragil, descripcion)
        SELECT PieceLength AS [length], 
               PieceWidth AS width, 
			   PieceHeight AS height,
               PieceWeight AS [weight], 
               Amount AS amount,
			   COALESCE(Currency, '') AS currency, 
			   COALESCE(ParcelCode,'') AS ParcelCode,
               CASE
                    WHEN fragile = 1 THEN
                        'true'
                    ELSE
                        'false'
                END AS fragil,
				COALESCE(Detail, '') AS [description]
        FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece] WITH (NOLOCK)
        WHERE GuideNumber = @Guide_Number
		AND GuideSerie = @Serie_Number
              AND GuidePiece =
              (
                  SELECT myrow FROM @TMPPICES WHERE it = @identity
              );
        SET @identity = @identity + 1;
        SET @i = @i - 1;
    END;

    IF (@arpieces IS NOT NULL AND LEN(@arpieces) > 0)
    BEGIN
        SET @arpieces = LEFT(@arpieces, LEN(@arpieces) - 1);
    END;
    /*select @arpieces as cicloresult*/
    /*end pieces*/

    /*start integration cost*/

    SELECT @j = COUNT(1)
    FROM DeliveryBackOffice.[dbo].[Cost] ct WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bdp WITH (NOLOCK)
            ON bdp.IdCost = ct.IdCost
    WHERE ct.GuideNumber =  @Guide_Number
		  AND ct.GuideSerie= @Serie_Number;

    SELECT TOP 1
           @identityCost = bdp.IdBreakdownOfPayment
    FROM DeliveryBackOffice.[dbo].[Cost] ct WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bdp WITH (NOLOCK)
            ON bdp.IdCost = ct.IdCost
    WHERE ct.GuideNumber =  @Guide_Number
		  AND ct.GuideSerie= @Serie_Number;

    WHILE @j > 0
    BEGIN
		INSERT INTO @Integration (Currency, [Description], Price)
        SELECT @calcurrency  AS Currency,
               [Description] , 
			   Amount AS Price
        FROM DeliveryBackOffice.[dbo].[Cost] ct WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bdp WITH (NOLOCK)
                ON bdp.IdCost = ct.IdCost
        WHERE ct.GuideNumber =  @Guide_Number
			  AND ct.GuideSerie= @Serie_Number
              AND IdBreakdownOfPayment = @identityCost;
        SET @identityCost = @identityCost + 1;
        SET @j = @j - 1;
    END;

    IF (@integrationCost IS NOT NULL AND LEN(@integrationCost) > 0)
    BEGIN
        SET @integrationCost = LEFT(@integrationCost, LEN(@integrationCost) - 1);
    END;

	SET @GuidePriority = (SELECT COUNT (do.Guide_Number) FROM DeliveryOrder do
		INNER JOIN Membership mb
		ON do.IdCustomer = mb.CustomerId
		WHERE do.Guide_Number = @Guide_Number
		AND do.Guide_Serie = @Serie_Number
		AND mb.CatMembershipStatusId = 3
		AND mb.ExpirationDate >= GETDATE()
		AND mb.RowStatus = 1)


		/* Agregar bandera para indicar que fue creado con suscripcion de monto fijo */
			DECLARE @PaymentAllowsCollect INT = (
			               	SELECT Top 1 COUNT(
										 Case 
											  When s.CatTypeSubscriptionId = 2 Then 1
											  When s.CatTypeSubscriptionId = 1 Then 0
											  When s.CatTypeSubscriptionId IS NULL Then 0 
											  ELSE 0 End)
							FROM dbo.MembershipSubscriptionLog MSL WITH (NoLock)
							INNER JOIN dbo.Subscription s WITH (NoLock)
							ON MSL.SubscriptionId = S.IdSubscription
							Where LogGuideNumber = @Guide_Number
							    AND LogGuideSerie = @Serie_Number
			
			
			)

		--------------------------------------------------------------------------------

    /*end integration cost*/

			SELECT DISTINCT TOP 1 --Price
					CONVERT(VARCHAR, ISNULL(dev.Preparation_Date, GETDATE()), 121) AS DateOfSale,
					dev.Package_Description AS ContentDescription, 
					--SE AGREGA EL ID DEL PAIS DESTINO Y SI TIENE INCIDENCIAS AL PAIS ORIGEN, CRISTIAN SUAZO
					CASE WHEN dev.IsLastMileReturn=0   
						THEN CONVERT(VARCHAR, COALESCE(dev.ReceiverCountryId, 'GT')) 
						ELSE CONVERT(VARCHAR, COALESCE(dev.SenderCountryId, 'GT'))
					END AS IdCountry,
					--FIN CAMBIO
					dev.Pieces_Dry + dev.Pieces_Cold AS CountPieces, 
					CASE
					WHEN dev.IsCollect = 1 THEN
						'true'
					ELSE
						'false'
				END AS Collected, 
				/*valor del felte para imprimir en la guia*/
				COALESCE(dev.PriceShippment, '0.00') AS Price, 
				COALESCE(@PaymentAllowsCollect, '0') AS PaymentAllowsCollect, 
				/*valor collect*/
				COALESCE(ctm.IdCustomer, vp.CustomerID, '0') AS IdCustomer,
				@TotalWeight AS TotalWeight,
				@TotalValue AS TotalValue,
				@calcurrency AS Currency,
				dev.InsuranceAmount AS ProductInsuranceAmount,
				@calcurrency AS InsuranceCurrency,
				COALESCE(dev.Sender_ID, 0) AS CodeOfReference,
				COALESCE(dev.Receiver_ID, 0) AS CodeOfReferenceDestiny,
				COALESCE(dev.Ticket_Number, '') AS IdInternalOrderRef,
				COALESCE([dev].[Order_Number], '') AS IdInternalOrderRef2,
				COALESCE(LOWER(dev.IndicationsToSendDestination),'') AS Service_Ref1,
				COALESCE(dev.OrderUserCreated, '') AS Username,
				COALESCE(DATEADD(DAY, @DaysToExpiration, dev.DateCreated), '') AS ExpirationDate,
				'' AS [Route],
				COALESCE(dev.TypeService, 'EXP') AS TypeService,
				COALESCE(CPT.TimePlaName, '') AS Service_Payment,
				CASE
					WHEN dev.IsInsuarance = 1 THEN
						'true'
					ELSE
						'false'
				END AS IsInsuarance,
				CASE
					WHEN dev.IsReturn = 1 THEN
						'true'
					ELSE
						'false'
				END AS IsReturn,
				CASE
					WHEN COALESCE(dev.VisitpointClientPortfolioId, 0) > 0 THEN
						dev.VisitpointClientPortfolioId
					ELSE
						0
				END AS VisitPointByClientPortfolioId,
				COALESCE(cdo.IdDeliveryOption, 0) AS idDeliveryOption,
				COALESCE(cdo.[Name], '') AS descriptionDelivery,
				@Impersonate AS Impersonate,
				COALESCE(@SalesChannel, 0) AS SaleChannel,
				CASE 
					WHEN ISNULL([dev].[IsLastMileReturn], 0) = 1 THEN 'D'
					WHEN MMBSHP.IdMembership IS NOT NULL THEN 'F'
					WHEN ctm.BusinessSegmentID = @IDCatBusinessB2B THEN 'B' 
					ELSE 'E'
				END AS [Priority],
				COALESCE(CONCAT('https://forzadelivery.com/rastreo/',Guide_Serie,Guide_Number), '') AS QRLink,
				COALESCE((CASE WHEN [MSL].[IdMembershipSubscriptionLog] IS NOT NULL THEN 1 ELSE 0 END), 0) AS UseMembership,
				IIF(CSBT.CatTypeSubscriptionId = 2, 0,1) AS AllowsCollect,
				IIF([MSL].[MembershipId] IS NOT NULL, CMSL.CatProductCategoryId,IIF(CSBT.CatProductCategoryId IS NOT NULL,CSBT.CatProductCategoryId, 0)) AS CategoryProductId,
				IIF([MSL].[MembershipId] IS NOT NULL,[MSL].[MembershipId], IIF(MSL.SubscriptionId IS NOT NULL,MSL.SubscriptionId, 0)) AS ProductId,
				COALESCE(dev.Pieces_Dry,'') AS Pieces_Dry,
				COALESCE([dev].[Pieces_Cold], '') AS Pieces_Cold,
				ISNULL(DSC.RouteCode,'') AS Route_Code,
				COALESCE(FORMAT([dev].[DeliveryETA], 'ddMM'), '') AS DeliveryETA,
				CASE
					WHEN ISNULL([dev].[IsCollect], 0) = 1 THEN 'COLLECT'
					WHEN [DOPD].[TimePlaId] = 1 THEN 'PREPAGO'
					WHEN [DOPD].[TimePlaId] = 2 THEN 'PICKUP'
					WHEN [DOPD].[TimePlaId] = 3 THEN 'COLLECT'
					WHEN [DOPD].[TimePlaId] = 4 THEN 'CRÉDITO'
					ELSE 'CRÉDITO'
				END AS WayToPayDescription,
				CASE
					WHEN [vp].[IdKindOfVPClient] = @FranchiseVisitPointTypeId THEN 'CNC'
					WHEN [vp].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN 'EXC'
					WHEN [vpori].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN 'EXC'
					WHEN [dev].[CatSystemId] = @IndividualWebSys THEN 'WEB'
					WHEN [dev].[CatSystemId] = @ExpressWebSys THEN 'EXC'
					WHEN [dev].[CatSystemId] = @CorporateWebSys THEN 'COR'
					WHEN [dev].[CatSystemId] = @ParserSys THEN 'PAR'
					WHEN [dev].[CatSystemId] IS NULL THEN 'API'
					ELSE 'API'
				END AS GuideOrigin,
				CASE
					WHEN 
						(dev.IsCollect <> 1 AND dev.Collect_OnDelivery>0 )
						OR ctm.Abbreviation IN ('IGSS','RENAP')
					THEN
						'D'
					ELSE
						''
				END AS Icon
			FROM DeliveryBackOffice.dbo.DeliveryOrder dev WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
				ON vp.CodeOfReference = dev.Sender_ID
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpori  WITH(NOLOCK) 
				ON [vpori].[CodeOfReference] = [dev].[OriginSenderId]
			LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
				ON ctm.IdCustomer = dev.IdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.Account acc WITH (NOLOCK)
				ON acc.IdCustomer = ctm.IdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rbu WITH (NOLOCK)
				ON rbu.RuaIdAccount = acc.AccIdAccount
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser rgu WITH (NOLOCK)
				ON rgu.UsrIdUser = rbu.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Person prs WITH (NOLOCK)
				ON prs.PerIdPerson = rgu.UsrIdPerson
			LEFT JOIN DeliveryBackOffice.dbo.Township tws WITH (NOLOCK)
				ON tws.IdTownship = dev.SenderIdTownship
			LEFT JOIN DeliveryBackOffice.dbo.Township tws2 WITH (NOLOCK)
				ON tws2.IdTownship = dev.ReceiverIdTownship
			LEFT JOIN DeliveryBackOffice.dbo.Province p WITH (NOLOCK)
				ON p.IdProvince = tws.IdProvince
			LEFT JOIN DeliveryBackOffice.dbo.Province p2 WITH (NOLOCK)
				ON p2.IdProvince = tws2.IdProvince
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba WITH (NOLOCK)
				ON dcba.DCBA_Id = dev.DCBA_ID
			LEFT JOIN DeliveryBackOffice.dbo.CatDeliveryOptions cdo WITH (NOLOCK)
				ON dev.IdDeliveryOption = cdo.IdDeliveryOption
			LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage cov WITH (NOLOCK)
				ON cov.HeaderCode = tws2.HeaderCode
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH (NOLOCK)
				ON DOPD.GuideNumber = dev.Guide_Number
			LEFT JOIN DeliveryBackOffice.dbo.CatPaymentTime CPT WITH (NOLOCK)
				ON DOPD.TimePlaId = CPT.TimePlaId
					AND cov.RowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.Membership MMBSHP WITH(NOLOCK)
				ON MMBSHP.CustomerId = ctm.IdCustomer
				AND MMBSHP.CatMembershipStatusId = @StatusPackage
				AND MMBSHP.ExpirationDate >= GETDATE()
				AND MMBSHP.RowStatus = 1
			LEFT JOIN [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL  WITH(NOLOCK) 
				ON [MSL].[LogGuideSerie] = [dev].[Guide_Serie] 
				AND [MSL].[LogGuideNumber] = [dev].[Guide_Number]
				AND [MSL].[RowStatus] = 1
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatMembership] CMSL  WITH(NOLOCK) 
				ON MMBSHP.CatMembershipId = CMSL.IdCatMembership
				AND CMSL.RowStatus = 1
			LEFT JOIN [DeliveryBackOffice].[dbo].[Subscription] SBT  WITH(NOLOCK) 
				ON MSL.SubscriptionId = SBT.IdSubscription
				AND SBT.RowStatus = 1
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CSBT  WITH(NOLOCK) 
				ON SBT.CatSubscriptionId = CSBT.IdCatSubscription
				AND CSBT.RowStatus = 1
			LEFT JOIN DumpServiceCoverage DSC WITH(NOLOCK)
				ON DSC.IdSettlement = dev.ReceiverIdSettlement
			WHERE dev.Guide_Number = @Guide_Number
					AND dev.Guide_Serie = @Serie_Number


			SELECT TOP 1 COALESCE(tws.HeaderCode, '') AS HeaderCodeTownship,
					CASE
						WHEN @Impersonate = 'TRUE' THEN
							--IMPERSONADO
							CASE
								WHEN (dev.IsReturn = 1) THEN
									--SI DEVOLUCION
									CASE
										WHEN (@customerType = 1) THEN
											--CORPORATIVO
											COALESCE(
														dev.Sender_FirstName,
														''
													)
										ELSE
											--INDIVIDUAL
											COALESCE(
														dev.Sender_FirstName,
														''
													)
									END
								ELSE
									-- NO DEVOLUCION
									CASE
										WHEN (@customerType = 1) THEN
											--CORPORATIVO
											COALESCE(
														vp.DescriptionOfClient,
														''
													)
										ELSE
											--INDIVIDUAL
											COALESCE(
														dev.Sender_FirstName,
														''
													)
									END
							END
						ELSE
							--NO IMPERSONADO
							COALESCE(dev.Sender_FirstName,'') + COALESCE(dev.Sender_LastName,'')
					END AS [name],
					COALESCE(dev.Sender_Phone, '') AS phone,
					COALESCE(rgu.UsrEmail, '') AS email,
					REPLACE(COALESCE(dev.Sender_Address, ''),'"','\"') AS address1,
					REPLACE(COALESCE(dev.TypeService, 'EXP'), '"', ' ') AS address2,
					CASE WHEN dev.IsLastMileReturn=1 THEN 
							'to_address'
						ELSE
							'from_address'
					END AS Adress,
					COALESCE(ctm.Abbreviation, '') AS city, 
					COALESCE(ctm.IdCustomer, vp.CustomerID, '0') AS IdMerchant,
					dev.IsLastMileReturn AS ReceiverIdSettlement, 
					CASE
						WHEN dev.[IsLastMileReturn] = 1 THEN ''
						WHEN @Impersonate = 'TRUE' THEN
							--IMPERSONADO
							CASE
								WHEN (dev.IsReturn = 1) THEN
									--SI DEVOLUCION
									CASE
										WHEN (@customerType = 1) THEN
											--CORPORATIVO
											COALESCE(@ExpressName, '')
										ELSE
											--INDIVIDUAL
											COALESCE(@ExpressName, '')
									END
								ELSE
									-- NO DEVOLUCION
									CASE
										WHEN (@customerType = 1) THEN
											--CORPORATIVO
											COALESCE(dev.Sender_FirstName, '')
										ELSE
											--INDIVIDUAL
											COALESCE(@ExpressName, '')
									END
							END
						ELSE
							--NO IMPERSONADO
							COALESCE(dev.Sender_FirstName, '') + ' '+ COALESCE(dev.Sender_LastName, '')
					END AS contact
			FROM DeliveryBackOffice.dbo.DeliveryOrder dev WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
				ON vp.CodeOfReference = dev.Sender_ID
			LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
				ON ctm.IdCustomer = dev.IdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.Account acc WITH (NOLOCK)
				ON acc.IdCustomer = ctm.IdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rbu WITH (NOLOCK)
				ON rbu.RuaIdAccount = acc.AccIdAccount
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser rgu WITH (NOLOCK)
				ON rgu.UsrIdUser = rbu.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Township tws WITH (NOLOCK)
				ON tws.IdTownship = dev.SenderIdTownship
			WHERE dev.Guide_Number = @Guide_Number
					AND dev.Guide_Serie = @Serie_Number
			UNION ALL
			SELECT TOP 1
				COALESCE(tws2.HeaderCode, '') AS HeaderCodeTownship,
				COALESCE(dev.Receiver_FirstName, '') + ' ' + COALESCE(dev.Receiver_LastName, '') AS [name],
				COALESCE(dev.Receiver_Phone, '') AS phone,
				COALESCE(dev.Receiver_Email, '') AS email,
				COALESCE(dev.Receiver_Address, '') AS address1,
				COALESCE(LOWER(dev.IndicationsToSendDestination), '') AS address2,
				CASE
					WHEN dev.IsLastMileReturn = 1 THEN
						'from_address'
					ELSE
						'to_address'
				END AS Adress,
				'' AS city,
				vp.CustomerID AS IdMerchant,
				COALESCE(dev.ReceiverIdSettlement, 0) AS ReceiverIdSettlement,
				COALESCE(dev.Receiver_Alternant_FullName, '') AS contact
			FROM DeliveryBackOffice.dbo.DeliveryOrder dev WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
					ON vp.CodeOfReference = dev.Sender_ID
				LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpori WITH (NOLOCK)
					ON [vpori].[CodeOfReference] = [dev].[OriginSenderId]
				LEFT JOIN DeliveryBackOffice.dbo.Township tws2 WITH (NOLOCK)
					ON tws2.IdTownship = dev.ReceiverIdTownship
			WHERE dev.Guide_Number = @Guide_Number
					AND dev.Guide_Serie = @Serie_Number

			SELECT [length],
				   width,
				   height,
				   [weight],
				   amount,
				   currency,
				   ParcelCode,
				   fragil,
				   descripcion
			FROM @Temp

			SELECT TOP 1 CASE
					WHEN dev.Collect_OnDelivery > 0 THEN
						'true'
					ELSE
						'false'
				END AS CashOnDelivery,
				COALESCE(dev.Order_Number, 0) AS CreditNumber,
				dev.Collect_OnDelivery AS AmmountCashOnDelivery,
				CASE 
					WHEN dev.SenderCountryId = 'GT' THEN 'GTQ'
					WHEN dev.SenderCountryId = 'HN' THEN 'HNL'
					ELSE 'HNL'
				END AS CashOnDeliveryCurrency,
				'AccountName' AS BankAccountName,
				dcba.DCBA_Bank_Id AS BankId,
				dcba.DCBA_BankAccountType AS BankAccountType,
				dcba.DCBA_Num_account AS BankAccountId,
				COALESCE(dcba.DCBA_Identification,'') AS Identification
			FROM DeliveryBackOffice.dbo.DeliveryOrder dev WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
				ON vp.CodeOfReference = dev.Sender_ID
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba WITH (NOLOCK)
				ON dcba.DCBA_Id = dev.DCBA_ID
			WHERE dev.Guide_Number = @Guide_Number
					AND dev.Guide_Serie = @Serie_Number

			SELECT Currency,
				   [Description],
				   Price
			FROM @Integration

END; 
