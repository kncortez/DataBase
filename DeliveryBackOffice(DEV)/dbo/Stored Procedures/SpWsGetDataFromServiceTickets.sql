
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2024-05-07>
-- Description:	< Agregar data de servicios y detalle para tabla dinamica en comprobante de pago, revalorizar gu�a si no contiene valor, soporta arreglo de varias gu�as >
-- =============================================

CREATE PROCEDURE [dbo].[SpWsGetDataFromServiceTickets]
    @IdAccount INT = 37,
    @TrackingNumber VARCHAR(MAX) = 'FD138358', --obtiene una cadena con N cantidad de gu�as separadas por comas 'FD138358,FD138359,...'
    @Token VARCHAR(100) = 'C6A98D3AB3A005C0023D634A6ECD1E5B'
AS
BEGIN

    BEGIN TRY

	-- Basado en el SP de SpWsGetDataFromServiceTicket
	-- CREACION DE TABLAS

	--INFORMACION QUE SE ENVIARA
	DECLARE @GuideDetails TABLE (
    IdCountry NVARCHAR(4),
    CountPieces INT,
    TotalWeight DECIMAL(18, 2),
    TotalValue DECIMAL(18, 2),
    TrackingNumber NVARCHAR(20),
    DeliveryDate NVARCHAR(50),
    Price DECIMAL(18, 2),
    Collected BIT,
	TypeService NVARCHAR(3),
    ContentDescription NVARCHAR(2500),
    TaxPayerNumber NVARCHAR(100),
    idInvoice BIGINT,
    VPDescriptionOfClient NVARCHAR(100),
    PriviceVisitPoint NVARCHAR(100),
    CountryVisitPoint NVARCHAR(100),
    VPAdress NVARCHAR(100),
    Mail NVARCHAR(200),
    FromName NVARCHAR(400),
    FromPhone VARCHAR(200),
    FromEmail NVARCHAR(400),
    FromAddress NVARCHAR(1200),
    FromCity NVARCHAR(200),
    ToName NVARCHAR(400),
    ToPhone VARCHAR(100),
    ToEmail NVARCHAR(200),
    ToAddress NVARCHAR(400),
    ToCity NVARCHAR(200)
	);

	DECLARE @PaymentDetails TABLE (
    ProductNumber NVARCHAR(100),
    Description NVARCHAR(100),
    Amount DECIMAL(18, 2)
	);		


	--INFORMACION QUE SE OBTENDRA POR CADA GU�A
	  DECLARE @TempTrackingNumbers TABLE (
		ID INT IDENTITY(1,1) PRIMARY KEY,
	    TrackingNumber VARCHAR(100),
        TotalWeight DECIMAL(18, 2),
        TotalValue DECIMAL(18, 2),
        ContentDescription VARCHAR(200),
        IdCost INT,
        Serie VARCHAR(2),
        NUMBER VARCHAR(20),
        COD DECIMAL(18, 2),
        COLLECT BIT,
		IsCard BIT
    );

	INSERT INTO @TempTrackingNumbers (
		TrackingNumber,
		TotalWeight,
		TotalValue,
		ContentDescription,
		IdCost,
		Serie,
		NUMBER,
		COD,
		COLLECT,
		IsCard
	)
	SELECT 
		s.Name AS TrackingNumber,
		SUM(DOP.PieceWeight) AS TotalWeight,
		SUM(DOP.Amount) AS TotalValue,
		MAX(DOP.Detail) AS ContentDescription,
		COALESCE(MAX(C.IdCost), 0) AS IdCost,
		SUBSTRING(s.Name, 1, 2) AS Serie,
		SUBSTRING(s.Name, 3, LEN(s.Name)) AS NUMBER,
		MAX(ISNULL(DO.Collect_OnDelivery, 0)) AS COD,
		MAX(CAST(DO.IsCollect AS INT)) AS COLLECT,
		MAX(CASE WHEN CCT.ReasonCode = 1 THEN 1 ELSE 0 END) AS IsCard
	FROM 
		dbo.splitstring(@TrackingNumber, ',') AS s
	LEFT JOIN 
		DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK) 
		ON DOP.GuideSerie = SUBSTRING(s.Name, 1, 2) 
		AND DOP.GuideNumber = SUBSTRING(s.Name, 3, LEN(s.Name))
	LEFT JOIN 
		dbo.Cost C WITH (NOLOCK) 
		ON C.ProductNumber = s.Name
	LEFT JOIN 
		dbo.DeliveryOrder DO WITH (NOLOCK)
		ON DO.Guide_Serie = SUBSTRING(s.Name, 1, 2) 
		AND DO.Guide_Number = SUBSTRING(s.Name, 3, LEN(s.Name))
	LEFT JOIN 
		dbo.CreditCardTransactionByCustomer CCT WITH (NOLOCK)
		ON CCT.OrderNumber = s.Name
	GROUP BY 
		s.Name;

	-- Declaraci�n de variables para iterar sobre las gu�as
    DECLARE @CurrentID INT = 1, @MaxID INT;
	DECLARE @FlagInsertEXC INT = 0;
    SELECT @MaxID = MAX(ID) FROM @TempTrackingNumbers;

    WHILE @CurrentID <= @MaxID
    BEGIN
        DECLARE @CurrentGuide VARCHAR(100), @CurrentSerie VARCHAR(2), @CurrentNumber VARCHAR(20),
                @CurrentCOLLECT BIT, @CurrentIsCard BIT, @CurrentIdCost INT, @CurrentCOD DECIMAL(18, 2);

        -- Obtener detalles de la gu�a actual
        SELECT @CurrentGuide = TrackingNumber, @CurrentSerie = Serie, @CurrentNumber = Number,
                @CurrentCOLLECT = COLLECT, @CurrentIsCard = IsCard, @CurrentIdCost = IdCost , @CurrentCOD = COD
        FROM @TempTrackingNumbers WHERE ID = @CurrentID;

        -- Ejecutar l�gica adicional por gu�a
        IF @CurrentCOLLECT = 1
        BEGIN
            EXEC [dbo].[spws_revalue_guide] @GuideSerie = @CurrentSerie,
                                            @GuideNumber = @CurrentNumber,
                                            @CodeApp = '',
                                            @Format = '',
                                            @CalculateTaxes = 'true',
                                            @IdModule = 1,
                                            @SetUpdate = 'true',
                                            @Token = @Token;

            -- Actualizar IdCost si es necesario
            SELECT TOP 1 @CurrentIdCost = C.IdCost
            FROM dbo.Cost C WITH (NOLOCK)
            WHERE C.ProductNumber = @CurrentGuide
            ORDER BY DateCreated DESC;

            UPDATE @TempTrackingNumbers
            SET IdCost = @CurrentIdCost
            WHERE ID = @CurrentID;
        END;
			
		IF @CurrentIdCost IS NULL
        BEGIN
            IF @CurrentIsCard = 1
            BEGIN
                EXEC [dbo].[spws_revalue_guide] 
                    @GuideSerie = @CurrentSerie,
                    @GuideNumber = @CurrentNumber,
                    @CodeApp = '',
                    @Format = '',
                    @CalculateTaxes = 'true', 
                    @IdModule = 1,
                    @SetUpdate = 'true',      
                    @Token = @Token,
                    @ParIsCreditCard = 1;

            END;
            ELSE
            BEGIN
                EXEC [dbo].[spws_revalue_guide] 
                    @GuideSerie = @CurrentSerie,
                    @GuideNumber = @CurrentNumber,
                    @CodeApp = '',
                    @Format = '',
                    @CalculateTaxes = 'true', 
                    @IdModule = 1,
                    @SetUpdate = 'true',      
                    @Token = @Token;
            END;

            -- Actualizar @CurrentIdCost despu�s de revalorizar la gu�a
            SELECT TOP 1 @CurrentIdCost = C.IdCost
            FROM dbo.Cost C WITH (NOLOCK)
            WHERE C.ProductNumber = @CurrentGuide AND C.IdModule <> 1
            ORDER BY DateCreated DESC;

            -- Actualizar IdCost en la tabla temporal
            UPDATE @TempTrackingNumbers
            SET IdCost = @CurrentIdCost
            WHERE ID = @CurrentID;
        END;

		IF (@IdAccount > 0 AND @CurrentIdCost > 0)
        BEGIN
			
			INSERT INTO @GuideDetails
			SELECT 
				PRV.IdCountry,
				DOR.Pieces_Cold + DOR.Pieces_Dry AS CountPieces,
				TTN.TotalWeight, -- Usando TotalWeight desde @TempTrackingNumbers
				COALESCE(DOR.Collect_OnDelivery, 0) AS TotalValue,
				DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) AS TrackingNumber,
				REPLACE(CONVERT(NVARCHAR, DOR.Delivery_Max_Date, 103), ' ', '/') AS DeliveryDate,
				DOR.PriceShippment AS Price,
				DOR.IsCollect AS Collected,
				DOR.TypeService AS TypeService,
				TTN.ContentDescription, -- Usando ContentDescription desde @TempTrackingNumbers
				IVH.inv_cli_nit AS TaxPayerNumber,
				IVH.inv_pk_id AS idInvoice,
				'',  -- VPDescriptionOfClient
				'',  -- PriviceVisitPoint
				'',  -- CountryVisitPoint
				'',  -- VPAdress
				ISNULL(rgu.UsrEmail, 'N/A') AS Mail,
				COALESCE(Receiver_FirstName, '') + ' ' + COALESCE(Receiver_LastName, '') AS FromName,
				Receiver_Phone AS FromPhone,
				COALESCE(Receiver_Email, '') AS FromEmail,
				Receiver_Address AS FromAddress,
				PRV2.ProvinceDescription AS FromCity,
				COALESCE(Sender_FirstName, '') + ' ' + COALESCE(Sender_LastName, '') AS ToName,
				Sender_Phone AS ToPhone,
				COALESCE(rgu.UsrEmail, '') AS ToEmail,
				Sender_Address AS ToAddress,
				PRV.ProvinceDescription AS ToCity
			FROM 
				DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Account ACC ON ACC.IdCustomer = DOR.IdCustomer
				LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rbu ON rbu.RuaIdAccount = ACC.AccIdAccount
				LEFT JOIN DeliveryBackOffice.dbo.RegisterUser rgu ON rgu.UsrIdUser = rbu.RuaIdUser
				LEFT JOIN DeliveryBackOffice.dbo.Township TOW ON TOW.IdTownship = DOR.SenderIdTownship
				LEFT JOIN DeliveryBackOffice.dbo.Province PRV ON PRV.IdProvince = TOW.IdProvince
				LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IVD WITH (NOLOCK) ON IVD.dti_fk_orderSerie = DOR.Guide_Serie AND IVD.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader IVH WITH (NOLOCK) ON IVH.inv_pk_id = IVD.dti_fk_header
				LEFT JOIN DeliveryBackOffice.dbo.Township TOW2 ON TOW2.IdTownship = DOR.ReceiverIdTownship
				LEFT JOIN DeliveryBackOffice.dbo.Province PRV2 ON PRV2.IdProvince = TOW2.IdProvince
				INNER JOIN @TempTrackingNumbers TTN ON TTN.TrackingNumber = DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number)
			WHERE 
				DOR.Guide_Serie = SUBSTRING(@CurrentGuide, 1, 2)
				AND DOR.Guide_Number = SUBSTRING(@CurrentGuide, 3, LEN(@CurrentGuide))
				AND ACC.AccIdAccount = @IdAccount;


			IF (@CurrentCOD > 0) ---- VALIDA QUE TIENE COD PARA AGREGAR A EL DETALLE
            BEGIN

				INSERT INTO @PaymentDetails (ProductNumber, Description, Amount)
				SELECT C.ProductNumber,
					   BOP.Description,
					   BOP.Amount
				FROM dbo.Cost C WITH (NOLOCK)
				INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
					ON C.IdCost = BOP.IdCost
				WHERE BOP.RowStatus = 1
					  AND BOP.Amount <> 0
					  AND C.ProductNumber = @CurrentGuide
					  AND BOP.IdCost = @CurrentIdCost
				UNION ALL
				SELECT @CurrentGuide AS ProductNumber,
					   'Valor de Mercaderia' AS Description,
					   @CurrentCOD AS Amount;

			END;
			ELSE
			BEGIN

				INSERT INTO @PaymentDetails (ProductNumber, Description, Amount)
				SELECT C.ProductNumber,
					   BOP.Description,
					   BOP.Amount
				FROM dbo.Cost C WITH (NOLOCK)
				INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
					ON C.IdCost = BOP.IdCost
				WHERE BOP.RowStatus = 1
					  AND BOP.Amount <> 0
					  AND C.ProductNumber = @CurrentGuide
					  AND BOP.IdCost = @CurrentIdCost

			END;

		END;
		ELSE
		BEGIN
		--Genera informacion para comprobante cuando para flujo impersonar Portal Web Express Center
			IF(@FlagInsertEXC = 0)
			BEGIN
				INSERT INTO @GuideDetails
				(
					IdCountry,
					CountPieces,
					TotalWeight,
					TotalValue,
					TrackingNumber,
					DeliveryDate,
					Price,
					Collected,
					TypeService,
					ContentDescription,
					TaxPayerNumber,
					idInvoice,
					VPDescriptionOfClient,
					PriviceVisitPoint,
					CountryVisitPoint,
					VPAdress,
					Mail,
					FromName,
					FromPhone,
					FromEmail,
					FromAddress,
					FromCity,
					ToName,
					ToPhone,
					ToEmail,
					ToAddress,
					ToCity
				)
				SELECT 
					PRV.IdCountry,
					DOR.Pieces_Cold + DOR.Pieces_Dry,
					TTN.TotalWeight,
					COALESCE(DOR.Collect_OnDelivery, 0),
					TTN.TrackingNumber,
					REPLACE(CONVERT(NVARCHAR, DOR.Delivery_Max_Date, 103), ' ', '/'),
					DOR.PriceShippment,
					DOR.IsCollect,
					DOR.TypeService,
					TTN.ContentDescription,
					IVH.inv_cli_nit,
					IVH.inv_pk_id,
					'',
					'',
					'',
					'',
					ISNULL(DOR.Receiver_Email, 'N/A'),
					COALESCE(Receiver_FirstName, '') + ' ' + COALESCE(Receiver_LastName, ''),
					Receiver_Phone,
					COALESCE(Receiver_Email, ''),
					Receiver_Address,
					PRV2.ProvinceDescription,
					CASE
						WHEN cu.IdCustomerType = 1 THEN
							CASE
								WHEN DOR.IsReturn = 1 THEN
									COALESCE(DOR.Sender_FirstName, '')
								ELSE
									COALESCE(vpc.DescriptionOfClient, '') + ' ' + COALESCE(Sender_LastName, '')
							END
						ELSE
							CASE
								WHEN DOR.IsReturn = 1 THEN
									COALESCE(DOR.Sender_FirstName, '')
								ELSE
									COALESCE(cu.Name, '')
							END
					END AS ToName,
					Sender_Phone,
					COALESCE(DOR.Sender_Mail, ''),
					Sender_Address,
					PRV.ProvinceDescription AS ToCity
				FROM 
					@TempTrackingNumbers TTN
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
					ON DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) = TTN.TrackingNumber
				LEFT JOIN DeliveryBackOffice.dbo.Township TOW
					ON TOW.IdTownship = DOR.SenderIdTownship
				LEFT JOIN DeliveryBackOffice.dbo.Province PRV
					ON PRV.IdProvince = TOW.IdProvince
				LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IVD WITH (NOLOCK)
					ON IVD.dti_fk_orderSerie = DOR.Guide_Serie AND IVD.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader IVH WITH (NOLOCK)
					ON IVH.inv_pk_id = IVD.dti_fk_header
				LEFT JOIN DeliveryBackOffice.dbo.Township TOW2
					ON TOW2.IdTownship = DOR.ReceiverIdTownship
				LEFT JOIN DeliveryBackOffice.dbo.Province PRV2
					ON PRV2.IdProvince = TOW2.IdProvince
				LEFT JOIN VisitPointClient vpc
					ON vpc.CodeOfReference = DOR.Sender_ID
				LEFT JOIN DeliveryBackOffice.dbo.Customer cu
					ON vpc.CustomerID = cu.IdCustomer
				WHERE 
					DOR.Guide_Serie = SUBSTRING(TTN.TrackingNumber, 1, 2)
					AND DOR.Guide_Number = SUBSTRING(TTN.TrackingNumber, 3, LEN(TTN.TrackingNumber));

				SET @FlagInsertEXC = 1;
			END

			IF (@CurrentCOD > 0) ---- VALIDA QUE TIENE COD PARA AGREGAR A EL DETALLE
            BEGIN

				INSERT INTO @PaymentDetails (ProductNumber, Description, Amount)
				SELECT C.ProductNumber,
					   BOP.Description,
					   BOP.Amount
				FROM dbo.Cost C WITH (NOLOCK)
				INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
					ON C.IdCost = BOP.IdCost
				WHERE BOP.RowStatus = 1
					  AND BOP.Amount <> 0
					  AND C.ProductNumber = @CurrentGuide
					  AND BOP.IdCost = @CurrentIdCost
				UNION ALL
				SELECT @CurrentGuide AS ProductNumber,
					   'Valor de Mercaderia' AS Description,
					   @CurrentCOD AS Amount;

			END;
			ELSE
			BEGIN

				INSERT INTO @PaymentDetails (ProductNumber, Description, Amount)
				SELECT C.ProductNumber,
					   BOP.Description,
					   BOP.Amount
				FROM dbo.Cost C WITH (NOLOCK)
				INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
					ON C.IdCost = BOP.IdCost
				WHERE BOP.RowStatus = 1
					  AND BOP.Amount <> 0
					  AND C.ProductNumber = @CurrentGuide
					  AND BOP.IdCost = @CurrentIdCost

			END;
		END;


        -- Incrementar ID para procesar la siguiente gu�a
        SET @CurrentID = @CurrentID + 1;
    END;

	--ENVIO DE DATOS
	SELECT * FROM @GuideDetails

	SELECT * FROM @PaymentDetails


    END TRY
    BEGIN CATCH

        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';

    END CATCH;
END;