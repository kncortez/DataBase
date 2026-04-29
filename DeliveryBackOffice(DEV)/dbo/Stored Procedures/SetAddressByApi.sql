/* =================================================
   SP:        [dbo].[SetAddressByApi]
   Propósito: Se agregan puntos de visita por medio de metodo de integración en API core.
   Autor:     Juan Ramirez
   Historia:  Desconocido
   Fecha:     2025-05-01
 ================ CHANGELOG ======================
2025-11-20 | Historia: FDAPI-4831 | Autor: Walter Orozco |
2026-04-28 | Historia: FDAPI-6138 | Autor: Oscar Rodriguez |
================================================= */

CREATE PROCEDURE [dbo].[SetAddressByApi]
(
   @CodeApp                NVARCHAR(60),
   @IdCountry              NVARCHAR(10)  = 'GT',
   @HeaderCode             NVARCHAR(10),
   @IdSettlement           INT = 0,      --Proviene de algoritmo
   @FullName               NVARCHAR(200),
   @Address1               NVARCHAR(600),
   @NirPhone               NVARCHAR(3),
   @Phone                  NVARCHAR(50),
   @Latitude               NVARCHAR(50)  = NULL,
   @Longitude              NVARCHAR(50)  = NULL,
   @Zone                   SMALLINT      = NULL,
   @Email                  NVARCHAR(200) = NULL,
   @KindOfVPClient		   NVARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables de control
    DECLARE @CodeOfReference    INT
           ,@IdCustomer         INT = 0
           ,@IdTownship         INT
           ,@IdProvince         INT
           ,@TownshipName       NVARCHAR(200)
           ,@ProvinceName       NVARCHAR(100)
           ,@IsOriginVisitPoint BIT = 1
           ,@IDVP               INT = -1
           ,@ResultNirPhone     NVARCHAR(3)
           ,@TransactionStarted INT = 0
           ,@ResultCreatedDate  NVARCHAR(100)
           ,@ResultEmail        NVARCHAR(200)
           ,@ResultPhone        NVARCHAR(50)
           ,@ResultCustomerId   INT
           ,@ResultAddress      NVARCHAR(600)
           ,@ResultFullName     NVARCHAR(200)
           ,@ResultPointId      BIGINT
           ,@IdResult           INT = 0
           ,@ErrorMessage       NVARCHAR(500) = 'Operación exitosa'
           ,@IsSuccess          BIT = 1
           ,@Date               DATETIME = GETDATE()
		   ,@SaleChannel		INT
		   ,@IsBoxful		    INT = 0;

      BEGIN TRY
                -- INICIAR TRANSACCIÓN
                IF @@TRANCOUNT = 0
                BEGIN
                    BEGIN TRANSACTION;
                    SET @TransactionStarted = 1;
                END

                SET @IdCustomer =
                    (
                      SELECT TOP 1
                             eco.IdCustomer
                        FROM DeliveryBackOffice.[dbo].[Ecommerce] eco WITH (NOLOCK)
                       WHERE eco.UserKey = @CodeApp
                         AND eco.IdCountry = @IdCountry
                         AND eco.EcommerceStatus = 1
                    );

                SELECT @ProvinceName = pv.ProvinceName,
                       @TownshipName = ts.TownshipName,
                       @IdTownship = ts.IdTownship,
                       @IdProvince = pv.IdProvince
                  FROM Province pv WITH(NOLOCK)
                       INNER JOIN Township ts with(nolock) ON pv.IdProvince = ts.IdProvince
                 WHERE ts.HeaderCode = @HeaderCode;

                -- VALIDACIÓN: Otro headerCode diferente al pais
                IF NOT EXISTS
                ( 
                         SELECT TOP 1 1
                           FROM Province pv WITH(NOLOCK)
                                INNER JOIN Township ts with(nolock) ON pv.IdProvince = ts.IdProvince
                          WHERE ts.HeaderCode = @HeaderCode
                            AND pv.IdCountry = @IdCountry
                ) 
                BEGIN
                     SELECT @IdResult = 409,
                            @ErrorMessage = 'No se encontró un HeaderCode valido con el país indicado.',
                            @IsSuccess = 0;

                     SELECT @ResultPointId = 0,
                            @ResultFullName = @FullName,
                            @ResultAddress = @Address1,
                            @ResultCustomerId = @IdCustomer,
                            @ResultPhone = @Phone,
                            @ResultNirPhone = @NirPhone,
                            @ResultEmail = @Email,
                            @ResultCreatedDate = GETDATE(),
                            @TownshipName = '',
                            @ProvinceName = '',
                            @IdProvince = 0,
                            @Latitude = @Latitude,
                            @Longitude = @Longitude

                    -- ROLLBACK porque no vamos a insertar
                    IF @TransactionStarted = 1
                    BEGIN
                        ROLLBACK TRANSACTION;
                        SET @TransactionStarted = 0;
                    END
                END 
                ELSE IF EXISTS (
                    SELECT TOP 1 1 
                      FROM dbo.VisitPointClient vpc WITH(NOLOCK)
                     WHERE vpc.DescriptionOfClient = @FullName 
                       AND vpc.CustomerID = @IdCustomer
                )
                BEGIN
                    SELECT @IdResult = 409,
                           @ErrorMessage = 'Ya existe un punto de visita con el mismo nombre para este cliente.',
                           @IsSuccess = 0;

                    -- Obtener información del punto existente
                    SELECT @ResultPointId = vpc.CodeOfReference,
                           @ResultFullName = vpc.DescriptionOfClient,
                           @ResultAddress = vpc.[Address],
                           @ResultCustomerId = vpc.CustomerID,
                           @ResultPhone =  CASE 
                                               WHEN vpc.Phone LIKE '(%' THEN
                                                   TRANSLATE(SUBSTRING(vpc.Phone, CHARINDEX(')', vpc.Phone) + 1, LEN(vpc.Phone)), '()- ', '    ')
                                               ELSE 
                                                   TRANSLATE(vpc.Phone, '()- ', '    ')
                                           END,
                           @ResultNirPhone = CASE
                                                 WHEN vpc.Phone LIKE '(%' THEN
                                                     SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), PATINDEX('%[^0-9]%', SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), 10)) - 1)
                                                 ELSE NULL
                                             END,
                           @ResultEmail = vpc.Email,
                           @ResultCreatedDate = vpc.DateCreated,
                           @TownshipName = vpc.Town,
                           @ProvinceName= vpc.Department,
                           @Latitude = vpc.Latitude,
                           @Longitude = vpc.Longitude
                      FROM dbo.VisitPointClient vpc WITH(NOLOCK)
                     WHERE vpc.DescriptionOfClient = @FullName 
                       AND vpc.CustomerID = @IdCustomer;

                    -- ROLLBACK porque no vamos a insertar
                    IF @TransactionStarted = 1
                    BEGIN
                        ROLLBACK TRANSACTION;
                        SET @TransactionStarted = 0;
                    END
                END
                ELSE IF EXISTS ( -- VALIDACIÓN 2: IdCustomer + Address (solo si no falló la primera)
                    SELECT TOP 1 1 
                      FROM dbo.VisitPointClient vpc WITH(NOLOCK)
                     WHERE vpc.CustomerID = @IdCustomer 
                       AND vpc.[Address] = @Address1
                )
                BEGIN
                    SELECT @IdResult = 409,
                           @ErrorMessage = 'Ya existe un punto de visita con la misma dirección para este cliente.',
                           @IsSuccess = 0;

                    -- Obtener información del punto existente
                    SELECT @ResultPointId = vpc.CodeOfReference,
                           @ResultFullName = vpc.DescriptionOfClient,
                           @ResultAddress = vpc.[Address],
                           @ResultCustomerId = vpc.CustomerID,
                           @ResultPhone =  CASE 
                                               WHEN vpc.Phone LIKE '(%' THEN
                                                   TRANSLATE(SUBSTRING(vpc.Phone, CHARINDEX(')', vpc.Phone) + 1, LEN(vpc.Phone)), '()- ', '    ')
                                               ELSE 
                                                   TRANSLATE(vpc.Phone, '()- ', '    ')
                                           END,
                           @ResultNirPhone = CASE
                                                 WHEN vpc.Phone LIKE '(%' THEN
                                                     SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), PATINDEX('%[^0-9]%', SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), 10)) - 1)
                                                 ELSE NULL
                                             END,
                           @ResultEmail = vpc.Email,
                           @ResultCreatedDate = vpc.DateCreated,
                           @TownshipName = vpc.Town,
                           @ProvinceName= vpc.Department,
                           @Latitude = vpc.Latitude,
                           @Longitude = vpc.Longitude
                      FROM dbo.VisitPointClient vpc WITH(NOLOCK)
                     WHERE vpc.CustomerID = @IdCustomer
                       AND vpc.[Address] = @Address1;

                   -- ROLLBACK porque no vamos a insertar
                   IF @TransactionStarted = 1
                   BEGIN
                       ROLLBACK TRANSACTION;
                       SET @TransactionStarted = 0;
                   END
                END
                ELSE IF EXISTS ( -- VALIDACIÓN 2: IdCustomer + Address (solo si no falló la primera)
                    SELECT TOP 1 1 
                      FROM dbo.VisitPointClient vpc WITH(NOLOCK)
                     WHERE vpc.CustomerID = @IdCustomer 
                       AND vpc.CountryId <> @IdCountry
                )
                BEGIN
                    SELECT @IdResult = 409,
                           @ErrorMessage = 'No es posible crear punto de visita para un pais diferente al del pais de origen del cliente',
                           @IsSuccess = 0;

                    -- Obtener información del punto existente
                    SELECT @ResultPointId = vpc.CodeOfReference,
                           @ResultFullName = vpc.DescriptionOfClient,
                           @ResultAddress = vpc.[Address],
                           @ResultCustomerId = vpc.CustomerID,
                           @ResultPhone =  CASE 
                                               WHEN vpc.Phone LIKE '(%' THEN
                                                   TRANSLATE(SUBSTRING(vpc.Phone, CHARINDEX(')', vpc.Phone) + 1, LEN(vpc.Phone)), '()- ', '    ')
                                               ELSE 
                                                   TRANSLATE(vpc.Phone, '()- ', '    ')
                                           END,
                           @ResultNirPhone = CASE
                                                 WHEN vpc.Phone LIKE '(%' THEN
                                                     SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), PATINDEX('%[^0-9]%', SUBSTRING(vpc.Phone, PATINDEX('%[0-9]%', vpc.Phone), 10)) - 1)
                                                 ELSE NULL
                                             END,
                           @ResultEmail = vpc.Email,
                           @ResultCreatedDate = vpc.DateCreated,
                           @TownshipName = vpc.Town,
                           @ProvinceName= vpc.Department,
                           @Latitude = vpc.Latitude,
                           @Longitude = vpc.Longitude
                      FROM dbo.VisitPointClient vpc WITH(NOLOCK)
                     WHERE vpc.CustomerID = @IdCustomer
                       AND vpc.[Address] = @Address1;

                    --ROLLBACK porque no vamos a insertar
                   IF @TransactionStarted = 1
                   BEGIN
                       ROLLBACK TRANSACTION;
                       SET @TransactionStarted = 0;
                   END
                END
                ELSE IF ( @IdCustomer = 0 
                          OR @IdCustomer IS NULL) -- VALIDACIÓN 3: 
                BEGIN
                     SELECT @IdResult = 409,
                            @ErrorMessage = 'No se encontró un cliente activo con los datos proporcionados.',
                            @IsSuccess = 0;

                     SELECT @ResultPointId = 0,
                            @ResultFullName = @FullName,
                            @ResultAddress = @Address1,
                            @ResultCustomerId = @IdCustomer,
                            @ResultPhone = @Phone,
                            @ResultNirPhone = @NirPhone,
                            @ResultEmail = @Email,
                            @ResultCreatedDate = GETDATE(),
                            @TownshipName = '',
                            @ProvinceName = '',
                            @IdProvince = 0,
                            @Latitude = @Latitude,
                            @Longitude = @Longitude

                     -- ROLLBACK porque no vamos a insertar
                     IF @TransactionStarted = 1
                     BEGIN
                         ROLLBACK TRANSACTION;
                         SET @TransactionStarted = 0;
                     END
                END 
                ELSE  -- Si no hay errores procedemos con el INSERT
                BEGIN
                     SET @CodeOfReference = (SELECT TOP (1) vpc3.CodeOfReference + 1 
                                               FROM dbo.VisitPointClient vpc3 WITH(NOLOCK)
                                              ORDER BY vpc3.CodeOfReference DESC)

					-- Se agrega tipo de punto de visita del cliente si lo trae, de lo contrario NULL
					DECLARE @IdKindOfVPClient INT = NULL;

					IF(@KindOfVPClient IS NOT NULL AND @KindOfVPClient <> '')
					BEGIN
						IF EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.KindOfVPClient WITH(NOLOCK) 
							WHERE KindOfVPName = @KindOfVPClient AND IdCountry = @IdCountry AND KindOfVPStatus = 1)
						BEGIN
							SELECT 
								@IdKindOfVPClient = IdKindOfVPClient
							FROM DeliveryBackOffice.dbo.KindOfVPClient WITH(NOLOCK) 
							WHERE KindOfVPName = @KindOfVPClient AND IdCountry = @IdCountry AND KindOfVPStatus = 1;
						END;
					END;

					-- Verificar cliente boxfull para asignacion de canal de ventas (B2C Agregadores)
					SET @IsBoxful = IIF(@IdCustomer IN (88813,83195),1,0)
					SET @SaleChannel = IIF(@IsBoxful = 1, (SELECT IdSalesChannel FROM DeliveryBackOffice.dbo.CatSalesChannel WITH(NOLOCK) WHERE Description = 'B2C Agregadores'), 0)

                    -- Verificar si ya contiene el guion
                    IF CHARINDEX('-', @Phone) = 0 AND LEN(@Phone) = 8
                    BEGIN
                        SET @Phone = STUFF(@Phone, 5, 0, '-');
                    END



                    INSERT INTO dbo.VisitPointClient
                    (
                        CodeOfReference,
                        DescriptionOfClient,
                        StatusClient,
                        CountryId,
                        VisitPointId,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated,
                        CustomerID,
                        [Address],
                        [Zone],
                        Town,
                        Department,
                        Phone,
                        ContactName,
                        IdKindOfVPClient,
                        IdKindOfVPBusiness,
                        IdSettlement,
                        Email,
                        IdTownship,
                        Latitude,
                        Longitude,
                        [IsOriginVisitPoint],
                        LogLatitude,
                        LogLongitude,
						SaleChannelId
                    )
                    VALUES
                    (
                      @CodeOfReference,                            -- CodeOfReference - int
                      LTRIM(RTRIM(@FullName)),                     -- DescriptionOfClient - nvarchar(100)
                      'TRUE',                                      -- StatusClient - bit
                      @IdCountry,                                  -- CountryId - nvarchar(2)
                      NULL,                                        -- VisitPointId - bigint
                      @CodeApp,                                    -- TokenCreated - nvarchar(50)
                      @Date,                                       -- DateCreated - datetime
                      NULL,                                        -- TokenUpdated - nvarchar(50)
                      NULL,                                        -- DateUpdated - datetime
                      @IdCustomer,                                 -- CustomerID - int
                      @Address1,                                   -- Address - nvarchar(600)
                      @Zone,                                       -- Zone - nvarchar(100)
                      @TownshipName,                               -- Town - nvarchar(100)
                      @ProvinceName,                               -- Department - nvarchar(100)
                      CONCAT('(',@NirPhone,') ',@Phone),           -- Phone - nvarchar(50)
                      '',                                          -- ContactName - nvarchar(200)
                      @IdKindOfVPClient,                           -- IdKindOfVPClient - int
                      NULL,                                        -- IdKindOfVPBusiness - int
                      IIF(@IdSettlement = 0, NULL,@IdSettlement),  -- IdSettlement - bigint
                      '',                                          -- Email - nvarchar(200)
                      @IdTownship,                                 -- IdTownship - int
                      @Latitude,                                   -- Latitude - varchar(50)
                      @Longitude,                                  -- Longitude - varchar(50)
                      @IsOriginVisitPoint,                         -- [IsOriginVisitPoint]
                      @Latitude,                                   -- LogLatitude
                      @Longitude,                                  -- LogLongitude
					  IIF(@IsBoxful = 1,@SaleChannel,NULL)		   -- SaleChannelId - Por defecto NULL
                    )

                    -- COMMIT de la transacción
                    IF @TransactionStarted = 1
                    BEGIN
                        COMMIT TRANSACTION;
                        SET @TransactionStarted = 0;
                    END

                    SELECT @IDVP = SCOPE_IDENTITY(),
                           @IdResult = 200,
                           @ErrorMessage = 'Punto de visita creado exitosamente.',
                           @IsSuccess = 1,
                           @ResultPointId = @CodeOfReference,
                           @ResultFullName = @FullName,
                           @ResultAddress = @Address1,
                           @ResultCustomerId = @IdCustomer,
                           @ResultNirPhone = @NirPhone,
                           @ResultPhone = @Phone,
                           @ResultEmail = @Email,
                           @ResultCreatedDate = @Date,
                           @ProvinceName = @ProvinceName,
                           @TownshipName = @TownshipName
                END
      END TRY
      BEGIN CATCH
           -- ROLLBACK en caso de error
           IF @TransactionStarted = 1 AND @@TRANCOUNT > 0
           BEGIN
               ROLLBACK TRANSACTION;
           END

           -- Manejo de errores de sistema
           SELECT @IdResult = ERROR_NUMBER(),
                  @ErrorMessage = CONCAT('Error del sistema: ',CAST(ERROR_MESSAGE() AS NVARCHAR(250))),
                  @IsSuccess = 0;
      END CATCH

      IF CHARINDEX('-', @ResultPhone) > 0
      BEGIN
          SET @ResultPhone = REPLACE(@ResultPhone, '-', '');
      END

      SELECT @IsSuccess AS IsSuccess,
             @IdResult AS IdResult,
             @ErrorMessage AS ErrorMessage,
             @ResultPointId AS CodeOfReference,
             @ResultFullName AS FullName,
             @ResultAddress AS [Address],
             @ResultCustomerId AS CustomerId,
             @ResultNirPhone AS NirPhone,
             REPLACE(@ResultPhone,' ','') AS Phone,
             @ResultEmail AS Email,
             @ResultCreatedDate AS CreatedDate,
             @ProvinceName AS ProvinceName,
             @TownshipName AS TownshipName,
             @IdProvince AS IdProvince,
             @Latitude AS Latitude,
             @Longitude AS Longitude,
             CASE 
                 WHEN @IsSuccess = 1 THEN 'CREATED'
                 WHEN @IdResult = 409 THEN 'DUPLICATE_ADDRESS'
                 ELSE 'SYSTEM_ERROR'
             END AS ResultType;

      RETURN;
END