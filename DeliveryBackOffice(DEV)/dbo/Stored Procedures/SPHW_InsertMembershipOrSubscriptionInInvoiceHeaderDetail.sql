-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-12-29>
-- Description:	<SP para insertar datos de cabecera de facturación de membresías o suscripciones>
-- =============================================
-- Actualizaciones: 
-- Author: Jerson Ochoa
-- Guardar identificador de membresía o suscripción en invoiceDetail - 16-01-2023
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-01-23>
-- Description:	<Agregar Log para registro de error>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-05-11>
-- Description:	<insertar vaoucher en tabla InOutOfMoneyDetail cuando es pago con dataphono tipo 6>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_InsertMembershipOrSubscriptionInInvoiceHeaderDetail]
    @TypeSalePackage AS NVARCHAR(50),
    @IdSalePackage INT,
    @IdAccount INT,
    @Token AS VARCHAR(200)
AS
BEGIN

    -- Datos cliente Cabecera de factura   
	

    DECLARE @inv_vpCodeOfReferences AS INT = (SELECT TOP 1 [VPC].[CodeOfReference] FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) WHERE VPC.[DescriptionOfClient] = 'EXPRESS CENTER CLUBFORZA'  COLLATE Latin1_General_CI_AI  AND VPC.[StatusClient] = 1);
    DECLARE @inv_cmp_nit AS VARCHAR(100) =
            (
                SELECT dpf_FELEntity
                FROM [dbo].[del_ParametrosFactura] WITH (NOLOCK)
                WHERE dpf_VpCodeOfReference = @inv_vpCodeOfReferences
            );
    DECLARE @inv_cli_name AS VARCHAR(200);
    DECLARE @inv_cli_adress AS VARCHAR(200);
    DECLARE @inv_cli_nit AS VARCHAR(200);
    DECLARE @inv_cli_email AS VARCHAR(200);
    DECLARE @inv_date AS DATETIME = GETDATE();
    DECLARE @inv_IVA AS MONEY;
    DECLARE @inv_amount AS MONEY;
    DECLARE @inv_status AS INT = 1;
    DECLARE @inv_dateRegister DATETIME = GETDATE();
    DECLARE @inv_tokenRegister VARCHAR(200) = @Token;
	DECLARE @typeMoneyId AS INT
    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------


    ------------------------------------------------------------------------------------
    --Datos detalle de factura
    DECLARE @dti_fk_header BIGINT;

    DECLARE @dti_identification VARCHAR(200) = 'SERVICIO';
    DECLARE @dti_category VARCHAR(50) = 'SERVICIO';
    DECLARE @dti_quantity DECIMAL(10, 5) = 1;
    DECLARE @dti_measurement VARCHAR(20) = 'UND';
    DECLARE @dti_priceUnit MONEY;
    DECLARE @dti_description VARCHAR(MAX) =
            (
                SELECT TOP 1
                       [Description]
                FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' COLLATE Latin1_General_CI_AI
            );
    DECLARE @dti_IVA MONEY;
    DECLARE @dti_amount MONEY;
    DECLARE @dti_dateRegister DATETIME = GETDATE();
    DECLARE @dti_tokenRegister VARCHAR(200) = @Token;
    DECLARE @SAPCode NVARCHAR(50) =
            (
                SELECT TOP 1
                       SAPCode
                FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' COLLATE Latin1_General_CI_AI
            );
    DECLARE @SendToInvoice BIT = 1;
    DECLARE @Descriptionp AS NVARCHAR(500);
    DECLARE @SuscriptionDesc AS NVARCHAR(200);
	DECLARE @Authorizacion AS NVARCHAR(20);
	DECLARE @IdMemberOrSuscription AS  NVARCHAR(200)
	DECLARE @MembershipId AS INT = NULL;
	DECLARE @SubscriptionId AS INT = NULL;

    SET @SuscriptionDesc =
    (
        SELECT TOP 1
               ISNULL(SubscriptionName, '')
        FROM [dbo].[CatSubscription] WITH (NOLOCK)
        WHERE IdCatSubscription = @IdSalePackage
    );

    IF (
           @SuscriptionDesc = 'Plan Básico'
           AND @TypeSalePackage <> 'Membership' COLLATE Latin1_General_CI_AI
       )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL A' COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Básico +'
                AND @TypeSalePackage <> 'Membership' COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL B' COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Gold'
                AND @TypeSalePackage <> 'Membership' COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL C' COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Corporativo'
                AND @TypeSalePackage <> 'Membership' COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL D' COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Diamante'
                AND @TypeSalePackage <> 'Membership' COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'MEMBRESIA DIAMANTE' COLLATE Latin1_General_CI_AI
    )   ;



    BEGIN TRANSACTION;
    BEGIN TRY

        IF (@TypeSalePackage = 'Membership' COLLATE Latin1_General_CI_AI)
        BEGIN

            SELECT TOP 1
			       @inv_amount = M.MembershipCost,
                   @inv_cli_email = M.InvoiceEmail,
                   @inv_cli_adress = M.FiscalAddress,
                   @inv_cli_nit = REPLACE(M.TaxIdNumber, '-', ''),
                   @inv_cli_name = M.InvoiceName,
                   @inv_IVA = M.MembershipCost - (M.MembershipCost / 1.12),
                   @Descriptionp = CM.MembershipName,
				   @IdMemberOrSuscription = M.IdMembership,
				   @MembershipId = M.IdMembership
            FROM [DeliveryBackOffice].[dbo].[Membership] M WITH (NOLOCK)
                INNER JOIN [dbo].[CatMembership] CM WITH (NOLOCK)
                    ON M.CatMembershipId = CM.IdCatMembership
            WHERE AccountId = @IdAccount
                  AND M.RowStatus = 1
                  AND CM.IdCatMembership = @IdSalePackage
				  ORDER BY M.DateCreated DESC

               SELECT  
					@Authorizacion = MOL.[TransactionOrder],
					@typeMoneyId = MOL.TypeOfInOutOfMoneyId
				  FROM [dbo].[MembershipPaymentLog] MOL WITH (NOLOCK) Where MembershipId =  @IdMemberOrSuscription
				  ORDER BY MOL.DateCreated DESC


        END;
        ELSE
        BEGIN



        Select  TOP 1
			    @inv_amount     = S.SubscriptionCost,
		        @inv_cli_email  = M.InvoiceEmail,
				@inv_cli_adress = M.FiscalAddress ,
				@inv_cli_nit    = REPLACE(M.TaxIdNumber,'-',''),
				@inv_cli_name   = M.InvoiceName,
				@inv_IVA  =   S.SubscriptionCost - (S.SubscriptionCost / 1.12),
				@Descriptionp = CS.SubscriptionName,
				@IdMemberOrSuscription = S.IdSubscription,
				@SubscriptionId = [S].[IdSubscription]
				From dbo.Membership M WITH (NOLOCK)
					Inner Join [dbo].[Subscription] S WITH (NOLOCK)
				ON M.IdMembership = s.MembershipId
					Inner Join dbo.CatSubscription CS
				ON s.CatSubscriptionId= cs.IdCatSubscription
				WHERE M.AccountId =   @IdAccount AND 
					  M.RowStatus = 1 AND 
				      CS.IdCatSubscription = @IdSalePackage
					  ORDER BY S.DateCreated DESC

				SET @dti_description = @dti_description +' '+   @Descriptionp

		  SELECT  TOP 1
		    @Authorizacion =  SOL.TransactionOrder,---SOL.[Authorization],
			@typeMoneyId = SOL.TypeOfInOutOfMoneyId
		  FROM [dbo].[SubscriptionPaymentLog]  SOL WITH (NOLOCK) Where SubscriptionId =  @IdMemberOrSuscription
		  ORDER BY SOL.DateCreated DESC


        END;


        INSERT INTO [dbo].[invoiceHeader]
        (
            inv_vpCodeOfReferences,
            inv_cmp_nit,
            inv_cli_name,
            inv_cli_adress,
            inv_cli_nit,
            inv_cli_email,
            inv_date,
            inv_IVA,
            inv_amount,
            inv_status,
            inv_dateRegister,
            inv_tokenRegister,
            inv_type
        )
        VALUES
        (@inv_vpCodeOfReferences, @inv_cmp_nit, @inv_cli_name, @inv_cli_adress, @inv_cli_nit, @inv_cli_email,
         @inv_date, @inv_IVA, @inv_amount, @inv_status, @inv_dateRegister, @inv_tokenRegister, 1);



        SET @dti_fk_header = SCOPE_IDENTITY();

        INSERT INTO [dbo].[invoiceDetail]
        (
            dti_fk_header,
            dti_identification,
            dti_category,
            dti_quantity,
            dti_measurement,
            dti_priceUnit,
            dti_description,
            dti_IVA,
            dti_amount,
            dti_dateRegister,
            dti_tokenRegister,
            SAPCode,
            SendToInvoice,
			MembershipId, 
			SubscriptionId
        )
        VALUES
        (@dti_fk_header, @dti_identification, @dti_category, @dti_quantity, @dti_measurement, @inv_amount,
         @dti_description, @inv_IVA, @inv_amount, @dti_dateRegister, @dti_tokenRegister, @SAPCode, @SendToInvoice,
		 @MembershipId,
		 @SubscriptionId);

		 INSERT INTO [dbo].[InOutOfMoneyDetail]
			   (
				[io_type],
				[io_vpCodeOfReferences],
				[io_ticket],
				[io_amount],
				[io_status],
				[io_invoice],
				[io_registryToken],
				[io_registryDate]
			   )
		 VALUES
			   (@typeMoneyId
			   ,@inv_vpCodeOfReferences
			   ,@Authorizacion
			   ,@inv_amount
			   ,@inv_status
			   ,@dti_fk_header
			   ,@token
			   ,GETDATE()
			   )

        COMMIT TRANSACTION;

        SELECT Result = 1,
               'Transacción exitosa' AS 'Description',
               @dti_fk_header IdInvoice,
               @inv_cli_email inv_cli_email,
               @Token Token;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT Result = 0,
               ERROR_MESSAGE() AS 'Description',
               IdInvoice = 0,
               @dti_fk_header IdInvoice,
               @inv_cli_email inv_cli_email,
               @Token Token;

		INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
		(
		    [ErrorDescription],
		    [ErrorNumber],
		    [ErrorProcedure],
		    [ErrorLine],
		    [GuideSerie],
		    [GuideNumber],
		    [TokenCreated],
		    [DateCreated]
		)
		VALUES
		(   CAST(ERROR_MESSAGE() AS NVARCHAR(300)),     -- ErrorDescription - varchar(300)
		    ERROR_NUMBER(),     -- ErrorNumber - int
		    ERROR_PROCEDURE(),     -- ErrorProcedure - varchar(100)
		    ERROR_LINE(),     -- ErrorLine - int
		    NULL,     -- GuideSerie - nvarchar(2)
		    NULL,     -- GuideNumber - int
		    '',       -- TokenCreated - varchar(50)
		    GETDATE() -- DateCreated - datetime
		    )
    END CATCH;
END;
