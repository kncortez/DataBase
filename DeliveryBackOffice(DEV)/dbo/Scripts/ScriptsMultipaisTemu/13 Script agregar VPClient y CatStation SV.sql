 
DECLARE @DescriptionOfClient NVARCHAR(100) = N'FD EXC SAN SALVADOR ESTE' -- Descripcion de express center comienza con FD
, @TokenSupport NVARCHAR(50) = N'SYS-WOROZCO'        -- Token de soporte
, @Address NVARCHAR(600) = N'Colonia Sierra Morena, Soyapango, San Salvador Este,El Salvador'             -- nvarchar(600)
, @IdTownship INT = 665            -- ID de la tabla Towship, municipio en al que pertenece el exc
, @zone INT = 0                  -- zona si aplica, sino dejar 0
, @Phone NVARCHAR(10) = N'55003355'               -- número de telefono XXXXXXXX
, @ContactName NVARCHAR(100) = N'Ross Maria Gonzales Veliz'         -- nvarchar(100) Contacto
, @Email NVARCHAR(100) = N'perkasorzo@gufum.com'               -- nvarchar(100) Correo
, @DescriptionCC NVARCHAR(100) = N'Express Center San Salvador Este Salvador'       -- nvarchar(100) Descripcion Narrada por Contact Center evitar siglas o abreviaturas
, @IdCountry NVARCHAR(2) = 'SV'			   -- Codigo de pais al que pertenecera el exc

    BEGIN TRY
	
		BEGIN TRANSACTION;
            
	DECLARE @PhoneNumber VARCHAR(50);
	-- Verificar si el formato es correcto (8 dígitos)
		IF @Phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		BEGIN
			
			DECLARE @AreaCode NVARCHAR(4) = (SELECT ISNULL(Value,'502') FROM DeliveryBackOffice.dbo.ConfigParams 
			WHERE Name = 'AreaCode' AND IdCountry = @IdCountry)

			-- Formatear la cadena
			SET @PhoneNumber = '('+@AreaCode+') ' + SUBSTRING(@Phone, 1, 4) + '-' + SUBSTRING(@Phone, 5, 4)
		END
		ELSE
		BEGIN
			--SELECT 'Formato telefonico incorrecto'
			RAISERROR('Formato telefonico incorrecto', 16, 1);
			RETURN;
		END

		IF NOT EXISTS
		(
			SELECT pr.IdProvince,
                   pr.ProvinceName,
                   tw.TownshipName
            FROM dbo.Township tw WITH (NOLOCK)
                INNER JOIN dbo.Province pr WITH (NOLOCK)
                    ON pr.IdProvince = tw.IdProvince
            WHERE  tw.IdTownship = @IdTownship
			AND ISNULL(pr.IdCountry,'GT') = @IdCountry
		)
		BEGIN
			RAISERROR('El municipio no pertene al pais especificado', 16, 1);
			RETURN;
		END

        IF NOT EXISTS -- verifica que el punto de visita no exista
        (
            SELECT *
            FROM dbo.VisitPointClient vp
            WHERE vp.DescriptionOfClient = @DescriptionOfClient
        )
        BEGIN		

            DECLARE @CodeOfReference INT;
            DECLARE @IdKindOfVPBusiness INT;
            DECLARE @IdKindOfVPClient INT;
            DECLARE @IdBusinessSegment INT;
			DECLARE @IdCustomer INT;

            SELECT @IdKindOfVPBusiness = IdKindOfVPBusiness
            FROM KindOfVPBusiness WITH(NOLOCK)
            WHERE Shorthand = 'EXP'
                  AND ISNULL(IdCountry, 'GT') = @IdCountry

            SELECT @IdKindOfVPClient = IdKindOfVPClient
            FROM KindOfVPClient WITH(NOLOCK)
            WHERE KindOfVPName = 'Express Center'
                  AND ISNULL(IdCountry, 'GT') = @IdCountry

            SELECT @IdBusinessSegment = IdBusinessSegment
            FROM CatBusinessSegment WITH(NOLOCK)
            WHERE BusinessSegmentName = 'C2C'
                  AND ISNULL(IdCountry, 'GT') = @IdCountry

			SELECT @IdCustomer = IdCustomer
            FROM Customer WITH(NOLOCK)
            WHERE Name like '%FD EXPRESS CENTER%'
				  AND IdCustomer IN(81, 82113) --gt,sv
                  AND ISNULL(CountryID, 'GT') = @IdCountry

            SELECT @CodeOfReference = MAX(vp.CodeOfReference) + 1
            FROM dbo.VisitPointClient vp
            --WHERE vp.IdKindOfVPBusiness = @IdKindOfVPBusiness;
            -- Obtener departamento y municipio

            DECLARE @IdProvice INT;
            DECLARE @ProvinceName NVARCHAR(100);
            DECLARE @TownshipName NVARCHAR(100);
			DECLARE @IdSettlement INT;


            SELECT TOP 1
					@IdProvice = pr.IdProvince,
					@ProvinceName = pr.ProvinceName,
					@TownshipName = tw.TownshipName,
					@IdSettlement = se.IdSettlement
            FROM dbo.Township tw WITH (NOLOCK)
                INNER JOIN dbo.Province pr WITH (NOLOCK)
                    ON pr.IdProvince = tw.IdProvince
				INNER JOIN dbo.Settlement se WITH (NOLOCK)
					ON se.IdProvince = pr.IdProvince AND se.IdTownship = tw.IdTownship
            WHERE tw.IdTownship = @IdTownship;
	

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
                Address,
                Zone,
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
                Accuracy,
                BranchCode,
                SaleChannelId,
                ExcludePriceShippingCOD,
                ExcludeCommissionCOD,
                IsOriginVisitPoint,
                LogLatitude,
                LogLongitude,
                DescriptionCC,
                CatBusinessSegmentId,
                AllowScheduledPickups,
				AttentionSchedule
            )
            VALUES
            (   @CodeOfReference,                        -- CodeOfReference - int
                @DescriptionOfClient,                    -- DescriptionOfClient - nvarchar(100)
                1,                                       -- StatusClient - bit
                @IdCountry,                              -- CountryId - nvarchar(2)
                NULL,                                    -- VisitPointId - bigint
                @TokenSupport,                           -- TokenCreated - nvarchar(50)
                GETDATE(),                               -- DateCreated - datetime
                NULL,                                    -- TokenUpdated - nvarchar(50)
                NULL,                                    -- DateUpdated - datetime
                @IdCustomer,                             -- CustomerID - int
                @Address,                                -- Address - nvarchar(600)
                CONVERT(NVARCHAR(2), @zone),             -- Zone - nvarchar(100)
                @TownshipName,                           -- Town - nvarchar(100)
                @ProvinceName,                           -- Department - nvarchar(100)
                @PhoneNumber,                            -- Phone - nvarchar(50)   (50x) xxxx-xxxx
                @ContactName,                            -- ContactName - nvarchar(200)
                @IdKindOfVPClient,                       -- IdKindOfVPClient - int Express Center   -- 1 EXC para GT, 12 EXC para HN
                @IdKindOfVPBusiness,                     -- IdKindOfVPBusiness - int EXPRESS CENTER -- 8 EXC para GT, 21 EXC para HN
                @IdSettlement,                           -- IdSettlement - bigint
                @Email,                                  -- Email - nvarchar(200)
                @IdTownship,                             -- IdTownship - int
                NULL,                                    -- Latitude - varchar(50)
                NULL,                                    -- Longitude - varchar(50)
                NULL,                                    -- Accuracy - varchar(50)
                CONVERT(NVARCHAR(50), @CodeOfReference), -- BranchCode - nvarchar(50)
                1,                                       -- SaleChannelId - int Express Center
                NULL,                                    -- ExcludePriceShippingCOD - bit
                NULL,                                    -- ExcludeCommissionCOD - bit
                1,                                       -- IsOriginVisitPoint - bit
                NULL,                                    -- LogLatitude - nvarchar(20)
                NULL,                                    -- LogLongitude - nvarchar(20)
                @DescriptionCC,                          -- DescriptionCC - nvarchar(100)
                @IdBusinessSegment,                      -- CatBusinessSegmentId - int 10	C2C GT --- int 21 C2C HN
                DEFAULT,                                 -- AllowScheduledPickups - bit
				NULL									 -- AttentionSchedule nvarchar(1000)
            );


            COMMIT;

			INSERT INTO CatStation VALUES (@DescriptionOfClient, @IdCountry,2,NULL,@CodeOfReference,1,@TokenSupport,GETDATE(),NULL,NULL);


            SELECT vp.CodeOfReference,
                   vp.DescriptionOfClient,
                   vp.TokenCreated,
                   vp.Address,
                   vp.Town,
                   vp.Department,
                   vp.Email
            FROM dbo.VisitPointClient vp WITH (NOLOCK)
            WHERE vp.CodeOfReference = @CodeOfReference;

			SELECT *
			FROM CatStation 
			WHERE CodeOfReference = @CodeOfReference

        END;
        ELSE
        BEGIN
            SELECT 'Este punto de visita ya existe';
        END;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_LINE(),
               ERROR_MESSAGE(),
               ERROR_NUMBER(),
               ERROR_STATE();

    END CATCH;
