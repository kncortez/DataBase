
--EXEC dbo.spws_get_services @StartDate = '', -- date
--                           @EndDate = '',   -- date
--                           @Pagina = 0,               -- bigint
--                           @Token = 'F3DE13B32D42925B7B585F5D95A2016F',               -- varchar(200)
--                           @IdAccount = 85054,            -- bigint
--                           @GuideNumber = N'',        -- nvarchar(50)
--                           @Filter = -1,               -- int
--                           @CancelGuides = 0          -- tinyint


-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-17>
-- Description:	<Devuelve el listado de GUIAS asiganadas a una cuenta>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-22>
-- Description:	< Mejora para que clientes corporativos solo se muestren registros por punto y no en general >
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_services_BNHL]
    -- Add the parameters for the stored procedure here
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Pagina BIGINT = 0,
    @Token VARCHAR(200),
    @IdAccount BIGINT,
    @GuideNumber AS NVARCHAR(50) = '-1',
    @Filter INT,
    @CancelGuides TINYINT = 1
AS
BEGIN    
set arithabort off
    DECLARE @IdUser BIGINT =
            (
                SELECT TOP 1 t.TknIdUser FROM TokenLog t WITH(NOLOCK) WHERE t.TknIdToken = @Token
            );
    IF OBJECT_ID('tempdb.dbo.#temp', 'U') IS NOT NULL
        DROP TABLE #temp;
    SELECT *
    INTO #temp
    FROM
    (
        SELECT ua.CodeOfReference
        FROM dbo.RolByUserByAccount rua WITH(NOLOCK)
            INNER JOIN dbo.UserAddress ua WITH(NOLOCK)
                ON ua.UadIdAccount = rua.RuaIdAccount
        WHERE rua.RuaIdAccount = @IdAccount
              AND rua.RuaIdUser = @IdUser
              AND rua.RuaRowStatus = 1
              AND ua.CodeOfReference IS NOT NULL
        UNION
        SELECT vpc.CodeOfReference
        FROM VisitPointByUser vpu WITH(NOLOCK)
            INNER JOIN dbo.VisitPointClient vpc WITH(NOLOCK)
                ON vpu.IdVisitPointClient = vpc.IdVisitPointClient
        WHERE RegisterUserID = @IdUser
    ) AS t;

    CREATE NONCLUSTERED INDEX idx_codeofreference ON #temp (CodeOfReference);

    DECLARE @idCustomer INT =
            (
                SELECT TOP 1 IdCustomer FROM Account WITH(NOLOCK) WHERE AccIdAccount = @IdAccount
            );

	-- Revisar tipo de usuario
	DECLARE @TypeUser NVARCHAR(20) = ''

	SELECT TOP 1
		@TypeUser = ctp.Description
	FROM dbo.InternalUser iu WITH(NOLOCK)
	INNER JOIN dbo.RegisterUser rg WITH(NOLOCK)
		ON rg.UsrIdUser = iu.RegisterUserID
	INNER JOIN dbo.RolByUserByAccount bya WITH(NOLOCK)
		ON bya.RuaIdUser = rg.UsrIdUser
	INNER JOIN dbo.Account acc WITH(NOLOCK)
		ON acc.AccIdAccount = bya.RuaIdAccount
	INNER JOIN dbo.Customer cs WITH(NOLOCK)
		ON cs.IdCustomer = acc.IdCustomer
	INNER JOIN dbo.CustomerType ctp WITH(NOLOCK)
		ON ctp.IdCustomerType = cs.IdCustomerType
	INNER JOIN dbo.TokenLog tl WITH(NOLOCK)
		ON tl.TknIdUser = bya.RuaIdUser
	WHERE tl.TknIdToken = @Token

	print (@TypeUser)
    DECLARE @jsonResult NVARCHAR(MAX);
    IF (@Pagina > -1)
    BEGIN
        IF (@Filter = -1)
        BEGIN
            SET NOCOUNT ON;
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				DECLARE @CantidadRegistrosC INT = 10;
				DECLARE @SKIPC BIGINT = @Pagina * @CantidadRegistrosC;

				DECLARE @counterC BIGINT
					=
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH(NOLOCK)
								INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
									ON sto.StatusOrderId = ord.StatusOrderId
								INNER JOIN
									#temp tp
									ON
										ord.Sender_ID = tp.CodeOfReference
							WHERE
								--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
								--AND
								(
									@CancelGuides = 0
									AND ISNULL(ord.StatusOrderId, 15) != 7
									OR @CancelGuides = 1
									   AND ord.StatusOrderId IS NOT NULL
								)
						);

					
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + '"Registros":"' + CONVERT(VARCHAR, @counterC) + '",' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(
																						   dbo.fnt_String_Escape(
																													ord.Sender_Address,
																													'json'
																												),
																						   'N/A'
																					   )
																				) AS VARCHAR),
																	  '"',
																	  ''
																  ),
														   'N/A'
													   ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + REPLACE(
															ISNULL(
																	  CONVERT(
																				 VARCHAR,
																				 CASE
																					 WHEN paydord.TypeofInOutMoneyId = 1 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 2 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 3 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 4 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 6 THEN
																						 UPPER('tarjeta')
																					 ELSE
																						 CASE
																							 WHEN ord.IsCollect = 1 THEN
																								 'EFECTIVO'
																							 ELSE
																								 CASE
																									 WHEN 1 = 1 /*
																									 (
																										 SELECT COUNT(*)
																										 FROM Cost C
																											 JOIN CostDetail CD
																												 ON C.IdCost = CD.IdCost
																													AND C.RowStatus = 1
																										 WHERE ProductNumber = CONCAT(
																																		 ord.Guide_Serie,
																																		 ord.Guide_Number
																																	 )
																									 ) > 1*/ THEN
																										 'TARJETA'
																									 WHEN
																									 (
																										 SELECT 1 FROM InternalUser WITH(NOLOCK) WHERE RegisterUserID = @IdUser
																									 ) = 1 THEN
																										 'EFECTIVO'
																									 ELSE
																										 'TARJETA'
																								 END
																						 END
																				 END
																			 ),
																	  'N/A'
																  ),
															'"',
															''
														) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId 
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch GB WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										WHERE
											--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
											--AND
											(
												@CancelGuides = 0
												AND ISNULL(ord.StatusOrderId, 15) != 7
												OR @CancelGuides = 1
												   AND ord.StatusOrderId IS NOT NULL
											)
										ORDER BY ord.Guide_Number DESC OFFSET @SKIPC ROWS FETCH NEXT @CantidadRegistrosC ROWS ONLY
                                   


										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
				
			END
			ELSE
			BEGIN
				
				DECLARE @CantidadRegistros INT = 10;
				DECLARE @SKIP BIGINT = @Pagina * @CantidadRegistros;




				DECLARE @counter BIGINT
					=
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH(NOLOCK)
								INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
									ON sto.StatusOrderId = ord.StatusOrderId
							WHERE
								--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
								--AND
								(
									((ord.Sender_ID IN
									  (
										  SELECT tp.CodeOfReference FROM #temp tp
									  )
									 )
									)
									OR (ord.OriginSenderId IN
										(
											SELECT tp.CodeOfReference FROM #temp tp
										)
									   )
									OR ord.IdCustomer = @idCustomer
								)
								AND
								(
									@CancelGuides = 0
									AND ISNULL(ord.StatusOrderId, 15) != 7
									OR @CancelGuides = 1
									   AND ord.StatusOrderId IS NOT NULL
								)
						);

						PRINT '@SKIP'
						PRINT @SKIP
						PRINT '@CantidadRegistros'
						PRINT @CantidadRegistros
						    PRINT CONVERT(VARCHAR, GETDATE(), 9);

				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + '"Registros":"' + CONVERT(VARCHAR, @counter) + '",' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(
																						   dbo.fnt_String_Escape(
																													ord.Sender_Address,
																													'json'
																												),
																						   'N/A'
																					   )
																				) AS VARCHAR),
																	  '"',
																	  ''
																  ),
														   'N/A'
													   ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + REPLACE(
															ISNULL(
																	  CONVERT(
																				 VARCHAR,
																				 CASE
																					 WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																					 WHEN paydord.TypeofInOutMoneyId = 1 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 2 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 3 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 4 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 6 THEN
																						 UPPER('tarjeta')
																					 ELSE
																						 CASE
																							 WHEN ord.IsCollect = 1 THEN
																								 'EFECTIVO'
																							 ELSE
																								 CASE
																									 WHEN 1 = 1 /*
																									 (
																										 SELECT COUNT(*)
																										 FROM Cost C
																											 JOIN CostDetail CD
																												 ON C.IdCost = CD.IdCost
																													AND C.RowStatus = 1
																										 WHERE ProductNumber = CONCAT(
																																		 ord.Guide_Serie,
																																		 ord.Guide_Number
																																	 )
																									 ) > 1*/ THEN
																										 'TARJETA'
																									 WHEN
																									 (
																										 SELECT 1 FROM InternalUser WITH(NOLOCK) WHERE RegisterUserID = @IdUser
																									 ) = 1 THEN
																										 'EFECTIVO'
																									 ELSE
																										 'TARJETA'
																								 END
																						 END
																				 END
																			 ),
																	  'N/A'
																  ),
															'"',
															''
														) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
												AND ord.Guide_Serie = paydord.GuideSerie
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										WHERE
											--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
											--AND
											(
												((ord.Sender_ID IN
												  (
													  SELECT tp.CodeOfReference FROM #temp tp
												  )
												 )
												)
												OR (ord.OriginSenderId IN
													(
														SELECT tp.CodeOfReference FROM #temp tp
													)
												   )
												OR ord.IdCustomer = @idCustomer
											)
											AND
											(
												@CancelGuides = 0
												AND ISNULL(ord.StatusOrderId, 15) != 7
												OR @CancelGuides = 1
												   AND ord.StatusOrderId IS NOT NULL
											)
											ORDER BY ord.Guide_Number 
											DESC OFFSET @SKIP ROWS FETCH NEXT @CantidadRegistros ROWS ONLY
                                   


										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
				    PRINT CONVERT(VARCHAR, GETDATE(), 9);
			END

            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN

                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se encontraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;

            SELECT ('[' + @jsonResult + ']') jsonResult;

        END;

        IF (@Filter = 1)
        BEGIN
            SET NOCOUNT ON;
            DECLARE @jsonResult1 NVARCHAR(MAX);
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				DECLARE @CantidadRegistros1C INT = 10;
				DECLARE @SKIP1C BIGINT = @Pagina * @CantidadRegistros1C;

				DECLARE @counter1C BIGINT
					=
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH(NOLOCK)
							INNER JOIN
								#temp tp
								ON
									ord.Sender_ID = tp.CodeOfReference
							WHERE
								--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
								--AND
								ord.StatusOrderId = 15
						);

				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Registros":"' + CONVERT(VARCHAR, @counter1C) + '",' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										WHERE
											--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
											--AND
											ord.StatusOrderId = 15
										ORDER BY ord.Guide_Number DESC OFFSET @SKIP1C ROWS FETCH NEXT @CantidadRegistros1C ROWS ONLY
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
				
			END
			ELSE
			BEGIN
				DECLARE @CantidadRegistros1 INT = 10;
				DECLARE @SKIP1 BIGINT = @Pagina * @CantidadRegistros1;

				DECLARE @counter1 BIGINT
					=
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH(NOLOCK)
							WHERE
								--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
								--AND
								ord.StatusOrderId = 15
								AND
								(
									((ord.Sender_ID IN
									  (
										  SELECT tp.CodeOfReference FROM #temp tp
									  )
									 )
									)
									OR (ord.OriginSenderId IN
										(
											SELECT tp.CodeOfReference FROM #temp tp
										)
									   )
									OR ord.IdCustomer = @idCustomer
								)
						);

				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Registros":"' + CONVERT(VARCHAR, @counter1) + '",' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship 
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
												ON ord.Guide_Number = paydord.GuideNumber  AND ord.Guide_Serie = paydord.GuideSerie
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch GB WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number AND gb.GuideSeries = ord.Guide_Serie

												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										WHERE
											--(( CONVERT(DATE, ord.DateCreated) between @StartDate and @EndDate) or (@StartDate IS NULL AND @EndDate IS NULL))
											--AND
											ord.StatusOrderId = 15
											AND
											(
												((ord.Sender_ID IN
												  (
													  SELECT tp.CodeOfReference FROM #temp tp
												  )
												 )
												)
												OR (ord.OriginSenderId IN
													(
														SELECT tp.CodeOfReference FROM #temp tp
													)
												   )
												OR ord.IdCustomer = @idCustomer
											)
										ORDER BY ord.Guide_Number DESC OFFSET @SKIP1 ROWS FETCH NEXT @CantidadRegistros1 ROWS ONLY
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);

			END
            
            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;
            SELECT ('[' + @jsonResult + ']') jsonResult;
        END;

        IF (@Filter = 2)
        BEGIN
            DECLARE @jsonResult2 NVARCHAR(MAX);
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				DECLARE @CantidadRegistros2C INT = 10;
				DECLARE @Skip2C BIGINT = @Pagina * @CantidadRegistros2C;

				DECLARE @counter2C BIGINT =
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH(NOLOCK)
							INNER JOIN
								#temp tp
								ON
									ord.Sender_ID = tp.CodeOfReference
							WHERE ISNULL(ord.StatusOrderId, 15) NOT IN ( 15, 5, 7, 22 )
						);

				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Registros":"' + CONVERT(VARCHAR, @counter2C) + '",' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_FirstName,
																													''
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Sender_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"NameReceiver":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Receiver_FirstName,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Receiver_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE ISNULL(ord.StatusOrderId, 15) NOT IN ( 15, 5, 7, 22 )
										ORDER BY ord.Guide_Number DESC OFFSET @Skip2C ROWS FETCH NEXT @CantidadRegistros2C ROWS ONLY
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
			END
			ELSE
			BEGIN
				DECLARE @CantidadRegistros2 INT = 10;
				DECLARE @Skip2 BIGINT = @Pagina * @CantidadRegistros2;

				DECLARE @counter2 BIGINT =
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH(NOLOCK)
							WHERE ISNULL(ord.StatusOrderId, 15) NOT IN ( 15, 5, 7, 22 )
								  AND
								  (
									  ((ord.Sender_ID IN
										(
											SELECT tp.CodeOfReference FROM #temp tp
										)
									   )
									  )
									  OR (ord.OriginSenderId IN
										  (
											  SELECT tp.CodeOfReference FROM #temp tp
										  )
										 )
									  OR ord.IdCustomer = @idCustomer
								  )
						);

				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Registros":"' + CONVERT(VARCHAR, @counter2) + '",' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_FirstName,
																													''
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Sender_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"NameReceiver":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Receiver_FirstName,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Receiver_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE ISNULL(ord.StatusOrderId, 15) NOT IN ( 15, 5, 7, 22 )
											  AND
											  (
												  ((ord.Sender_ID IN
													(
														SELECT tp.CodeOfReference FROM #temp tp
													)
												   )
												  )
												  OR (ord.OriginSenderId IN
													  (
														  SELECT tp.CodeOfReference FROM #temp tp
													  )
													 )
												  OR ord.IdCustomer = @idCustomer
											  )
										ORDER BY ord.Guide_Number DESC OFFSET @Skip2 ROWS FETCH NEXT @CantidadRegistros2 ROWS ONLY
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
			END
            
            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;
            SELECT ('[' + @jsonResult + ']') jsonResult;

        END;


        IF (@Filter = 3)
        BEGIN

            SET NOCOUNT ON;

            DECLARE @jsonResult3 NVARCHAR(MAX);
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				DECLARE @CantidadRegistros3C INT = 10;
				DECLARE @Skip3C BIGINT = @Pagina * @CantidadRegistros3C;


				DECLARE @counter3C BIGINT =
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH (NOLOCK)
							INNER JOIN
								#temp tp
								ON
									ord.Sender_ID = tp.CodeOfReference
							WHERE ord.StatusOrderId IN ( 5, 22 )
						);


				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{"Guide":"' + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' + 
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   '"Registros":"' + CONVERT(VARCHAR, @counter3C) + '",' + '"IdBatch":'
											   + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ',' + '"RequestDate":"'
											   + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
													AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE ord.StatusOrderId IN ( 5, 22 )
										ORDER BY ord.Guide_Number DESC OFFSET @Skip3c ROWS FETCH NEXT @CantidadRegistros3c ROWS ONLY
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
			END
			ELSE
			BEGIN
				DECLARE @CantidadRegistros3 INT = 10;
				DECLARE @Skip3 BIGINT = @Pagina * @CantidadRegistros3;


				DECLARE @counter3 BIGINT =
						(
							SELECT COUNT(ORD.Guide_Number)
							FROM dbo.DeliveryOrder ord WITH (NOLOCK)
							WHERE ord.StatusOrderId IN ( 5, 22 )
								  AND
								  (
									  ((ord.Sender_ID IN
										(
											SELECT tp.CodeOfReference FROM #temp tp
										)
									   )
									  )
									  OR (ord.OriginSenderId IN
										  (
											  SELECT tp.CodeOfReference FROM #temp tp
										  )
										 )
									  OR ord.IdCustomer = @idCustomer
								  )
						);


				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{"Guide":"' + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
												+ '"Registros":"' + CONVERT(VARCHAR, @counter3) + '",' + '"IdBatch":'
											   + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ',' + '"RequestDate":"'
											   + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH(NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH(NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH(NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH(NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH(NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH(NOLOCK)
											ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH(NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH(NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH(NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH(NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE ord.StatusOrderId IN ( 5, 22 )
											  AND
											  (
												  ((ord.Sender_ID IN
													(
														SELECT tp.CodeOfReference FROM #temp tp
													)
												   )
												  )
												  OR (ord.OriginSenderId IN
													  (
														  SELECT tp.CodeOfReference FROM #temp tp
													  )
													 )
												  OR ord.IdCustomer = @idCustomer
											  )
										ORDER BY ord.Guide_Number DESC OFFSET @Skip3 ROWS FETCH NEXT @CantidadRegistros3 ROWS ONLY
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);

			END
            
            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN

                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;

            SELECT ('[' + @jsonResult + ']') jsonResult;

        END;

    END;
    ELSE
    BEGIN
        IF (@Filter = -1)
        BEGIN
		
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(
																						   dbo.fnt_String_Escape(
																													ord.Sender_Address,
																													'json'
																												),
																						   'N/A'
																					   )
																				) AS VARCHAR),
																	  '"',
																	  ''
																  ),
														   'N/A'
													   ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + REPLACE(
															ISNULL(
																	  CONVERT(
																				 VARCHAR,
																				 CASE
																					 WHEN paydord.TypeofInOutMoneyId = 1 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 2 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 3 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 4 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 6 THEN
																						 UPPER('tarjeta')
																					 ELSE
																						 CASE
																							 WHEN ord.IsCollect = 1 THEN
																								 'EFECTIVO'
																							 ELSE
																								 CASE
																									 WHEN 1 = 1 /*
																									 (
																										 SELECT COUNT(*)
																										 FROM Cost C
																											 JOIN CostDetail CD
																												 ON C.IdCost = CD.IdCost
																													AND C.RowStatus = 1
																										 WHERE ProductNumber = CONCAT(
																																		 ord.Guide_Serie,
																																		 ord.Guide_Number
																																	 )
																									 ) > 1*/ THEN
																										 'TARJETA'
																									 WHEN
																									 (
																										 SELECT 1 FROM InternalUser WITH(NOLOCK) WHERE RegisterUserID = @IdUser
																									 ) = 1 THEN
																										 'EFECTIVO'
																									 ELSE
																										 'TARJETA'
																								 END
																						 END
																				 END
																			 ),
																	  'N/A'
																  ),
															'"',
															''
														) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie )
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)                                        
											LEFT JOIN dbo.Township twn WITH (NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
										AND ORD.StatusOrderId <> IIF(@CancelGuides =0,7,0)
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);

		
			END
			ELSE
			BEGIN

			PRINT 'ENTRA ACÁ'

				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + '"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(
																						   dbo.fnt_String_Escape(
																													ord.Sender_Address,
																													'json'
																												),
																						   'N/A'
																					   )
																				) AS VARCHAR),
																	  '"',
																	  ''
																  ),
														   'N/A'
													   ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + REPLACE(
															ISNULL(
																	  CONVERT(
																				 VARCHAR,
																				 CASE
																					 WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																					 WHEN paydord.TypeofInOutMoneyId = 1 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 2 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 3 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 4 THEN
																						 UPPER(ctgmon.tio_pk_name)
																					 WHEN paydord.TypeofInOutMoneyId = 6 THEN
																						 UPPER('tarjeta')
																					 ELSE
																						 CASE
																							 WHEN ord.IsCollect = 1 THEN
																								 'EFECTIVO'
																							 ELSE
																								 CASE
																									 WHEN 1 = 1 /*
																									 (
																										 SELECT COUNT(*)
																										 FROM Cost C
																											 JOIN CostDetail CD
																												 ON C.IdCost = CD.IdCost
																													AND C.RowStatus = 1
																										 WHERE ProductNumber = CONCAT(
																																		 ord.Guide_Serie,
																																		 ord.Guide_Number
																																	 )
																									 ) > 1*/ THEN
																										 'TARJETA'
																									 WHEN
																									 (
																										 SELECT 1 FROM InternalUser WITH(NOLOCK) WHERE RegisterUserID = @IdUser
																									 ) = 1 THEN
																										 'EFECTIVO'
																									 ELSE
																										 'TARJETA'
																								 END
																						 END
																				 END
																			 ),
																	  'N/A'
																  ),
															'"',
															''
														) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)                                        
											LEFT JOIN dbo.Township twn WITH (NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
										AND (ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR	ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR ord.IdCustomer = @idCustomer
											)
										AND ORD.StatusOrderId <> IIF(@CancelGuides =0,7,0)
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
			END

			PRINT 'ENTRA ACÁ 2'
            
            IF @jsonResult IS NULL
            BEGIN

                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se encontraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;

            SELECT ('[' + @jsonResult + ']') jsonResult;
        END;
        IF (@Filter = 1)
        BEGIN

		
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
			print('aqui si')
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie )
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
									
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
			END
			ELSE
			BEGIN
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR(100)),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
										AND (ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR	ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR ord.IdCustomer = @idCustomer
											)
									
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);

			END
            
            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;
            SELECT ('[' + @jsonResult + ']') jsonResult;
        END;
        IF (@Filter = 2)
        BEGIN
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_FirstName,
																													''
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Sender_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"NameReceiver":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Receiver_FirstName,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Receiver_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH (NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
										AND ORD.StatusOrderId <> IIF(@CancelGuides =0,7,0)
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
			END
			ELSE
			BEGIN
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{' + +'"Guide":"'
											   + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_FirstName,
																													''
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Sender_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"NameReceiver":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Receiver_FirstName,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ) + ' '
																					+ REPLACE(
																								 CAST(UPPER(ISNULL(
																													  ord.Receiver_LastName,
																													  ''
																												  )
																										   ) AS VARCHAR),
																								 '"',
																								 ''
																							 ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH (NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
										AND (ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR	ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR ord.IdCustomer = @idCustomer
											)
										AND ORD.StatusOrderId <> IIF(@CancelGuides =0,7,0)
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);
			END
            
            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;
            SELECT ('[' + @jsonResult + ']') jsonResult;

        END;
        IF (@Filter = 3)
        BEGIN
			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{"Guide":"' + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' 
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH (NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											INNER JOIN
												#temp tp
												ON
													ord.Sender_ID = tp.CodeOfReference
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
									
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);

			END
			ELSE
			BEGIN
				SET @jsonResult =
				(
					SELECT STUFF(
									(
										SELECT ',{"Guide":"' + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' 
											   +'"Pieces":' + ISNULL(CONVERT(VARCHAR, (ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0))),'') + ',' +
											   +'"Reference":"' + ISNULL(ord.Ticket_Number,'') + '",' +
												+'"ReceiverPhone":"' + ISNULL(ord.Receiver_Phone,'') + '",' +
											   + '"IdBatch":' + CONVERT(NVARCHAR, ISNULL(gb.IdBatch, '')) + ','
											   + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
											   + '",' + '"Source":"'
											   + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
											   + '"Destiny":"'
											   + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
											   + '"NameofSender":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Sender_FirstName, '')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Sender_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"NameReceiver":"'
											   + ISNULL(
														   REPLACE(
																	  CAST(UPPER(ISNULL(ord.Receiver_FirstName, 'N/A')) AS VARCHAR),
																	  '"',
																	  ''
																  ) + ' '
														   + REPLACE(
																		CAST(UPPER(ISNULL(ord.Receiver_LastName, '')) AS VARCHAR),
																		'"',
																		''
																	),
														   'N/A'
													   ) + '",' + '"AddresofSender":"'
											   + dbo.fnt_String_Escape(
																		  ISNULL(
																					REPLACE(
																							   CAST(UPPER(ISNULL(
																													ord.Sender_Address,
																													'N/A'
																												)
																										 ) AS VARCHAR),
																							   '"',
																							   ''
																						   ),
																					'N/A'
																				),
																		  'json'
																	  ) + '",' + '"Impersonate":'
											   + (CASE
													  WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN
														  'true'
													  ELSE
														  'false'
												  END
												 ) + ',' + '"DateRecoleccion":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"DateProgramadaEntrega":"'
											   + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A')
											   + '",' + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
											   +
											--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
											'"PrecioServicio":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1)
											   + '",' + '"CollectOnDelivery":"'
											   + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
											   + '",' + '"ShippmentComplete":'
											   + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
											   + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
											   + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A')
											   + '",' + '"WayToPay":"'
											   + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
													 'PENDIENTE',
													 (ISNULL(
																CONVERT(
																		   VARCHAR,
																		   CASE
																			   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
																			   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																				   UPPER(catpay.PayTypeName)
																			   WHEN paydord.TypeofInOutMoneyId = 8 THEN
																				   UPPER('credito')
																			   ELSE
																				   CASE
																					   WHEN ord.IsCollect = 1 THEN
																						   'COLLECT'
																					   ELSE
																						   'CONTADO'
																				   END
																		   END
																	   ),
																'N/A'
															)
													 )) + '",' + '"TimePayment":"'
											   + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
											   + '"TimePaymentDescription":"'
											   + ISNULL(
														   CONVERT(   VARCHAR,
														   (
															   SELECT TimePlaName
															   FROM DeliveryBackOffice.dbo.CatPaymentTime TMD WITH(NOLOCK)
															   WHERE paydord.TimePlaId = TMD.TimePlaId
														   )
																  ),
														   ''
													   ) + '",' + '"TypePayment":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
																	   WHEN paydord.TypeofInOutMoneyId = 1 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 2 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 3 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 4 THEN
																		   UPPER(ctgmon.tio_pk_name)
																	   WHEN paydord.TypeofInOutMoneyId = 6 THEN
																		   UPPER('tarjeta')
																	   ELSE
																		   CASE
																			   WHEN ord.IsCollect = 1 THEN
																				   'EFECTIVO'
																			   ELSE
																				   'TARJETA'
																		   END
																   END
															   ),
														'N/A'
													   ) + '",' + '"CollectDelivery":"'
											   + ISNULL(CONVERT(   VARCHAR,
																   CASE
																	   WHEN ord.IsCollect = 1 THEN
																		   'SI'
																	   ELSE
																		   'NO'
																   END
															   ),
														'N/A'
													   ) + '",' + +'"TypeService":"'
											   + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
										FROM dbo.DeliveryOrder ord WITH (NOLOCK)
											LEFT JOIN dbo.Township twn WITH (NOLOCK)
												ON twn.IdTownship = ord.SenderIdTownship
											LEFT JOIN dbo.Province pr WITH (NOLOCK)
												ON pr.IdProvince = twn.IdProvince
											LEFT JOIN dbo.Township twd WITH (NOLOCK)
												ON twd.IdTownship = ord.ReceiverIdTownship
											LEFT JOIN dbo.Province prd WITH (NOLOCK)
												ON prd.IdProvince = twd.IdProvince
											INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
												ON sto.StatusOrderId = ord.StatusOrderId
											LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord WITH (NOLOCK)
												ON (ord.Guide_Number = paydord.GuideNumber AND ord.Guide_Serie = paydord.GuideSerie)
											LEFT JOIN [dbo].[CatPaymentType] catpay WITH (NOLOCK)
												ON (catpay.PayTypeId = paydord.PayTypeId)
											LEFT JOIN [dbo].[CatPaymentTime] cattime WITH (NOLOCK)
												ON (cattime.TimePlaId = paydord.TimePlaId)
											LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon WITH (NOLOCK)
												ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
											LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
												ON gb.GuideNumber = ord.Guide_Number
												AND gb.GuideSeries = ord.Guide_Serie
												   AND gb.RowStatus = 1
											LEFT JOIN
												[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
												ON
													ord.Guide_Serie = PBSL.GuideSerie
													AND
													ord.Guide_Number = PBSL.GuideNumber
													AND
													PBSL.PointsConsumed > 0
													AND
													PBSL.PointsReceived = 0
										--LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
										WHERE CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate
										AND (ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR	ord.Sender_ID IN(SELECT tp.CodeOfReference FROM #temp tp)

											OR ord.IdCustomer = @idCustomer
											)
									
										ORDER BY ord.Guide_Number DESC
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),
									1,
									1,
									''
								)
				);

			END
            
            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN

                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;

            SELECT ('[' + @jsonResult + ']') jsonResult;
        END;

    END;

END;