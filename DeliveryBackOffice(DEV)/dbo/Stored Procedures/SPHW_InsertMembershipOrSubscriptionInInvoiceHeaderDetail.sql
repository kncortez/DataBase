-- Description:	<Agregar Log para registro de error>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-05-11>
-- Description:	<insertar vaoucher en tabla InOutOfMoneyDetail cuando es pago con dataphono tipo 6>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-05-11>
-- Description:	<Validación de NIT no admite CF si el monto de la suscripción es mayor a 2500 >
-- =============================================
CREATE procedure [dbo].[SPHW_InsertMembershipOrSubscriptionInInvoiceHeaderDetail]
    @TypeSalePackage as nvarchar(50)
  , @IdSalePackage int
  , @IdAccount int
  , @Token as varchar(200)
  -- Datos de Facturación
  , @TaxId nvarchar(50) = 'CF'
  , @FiscalAddress nvarchar(200) = 'Guatemala'
  , @TaxName nvarchar(100) = 'Consumidor Final'
  , @InvoiceEmail nvarchar(50) = ''
as
begin

    -- Datos cliente Cabecera de factura   


    declare @inv_vpCodeOfReferences as int =
            (
                select top 1
                       [VPC].[CodeOfReference]
                from [DeliveryBackOffice].[dbo].[VisitPointClient] VPC with (nolock)
                where VPC.[DescriptionOfClient] = 'EXPRESS CENTER CLUBFORZA' collate Latin1_General_CI_AI
                      and VPC.[StatusClient] = 1
            );
    declare @inv_cmp_nit as varchar(100) =
            (
                select dpf_FELEntity
                from [dbo].[del_ParametrosFactura] with (nolock)
                where dpf_VpCodeOfReference = @inv_vpCodeOfReferences
            );
    declare @inv_cli_name as varchar(200);
    declare @inv_cli_adress as varchar(200);
    declare @inv_cli_nit as varchar(200);
    declare @inv_cli_email as varchar(200);
    declare @inv_date as datetime = getdate();
    declare @inv_IVA as money;
    declare @inv_amount as money;
    declare @inv_status as int = 1;
    declare @inv_dateRegister datetime = getdate();
    declare @inv_tokenRegister varchar(200) = @Token;
    declare @typeMoneyId as int;
    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------

    select top 1
           @inv_cli_name   = InvoiceName
         , @inv_cli_nit    = TaxIdNumber
         , @inv_cli_email  = InvoiceEmail
         , @inv_cli_adress = FiscalAddress
    from [DeliveryBackOffice].[dbo].[Membership] M
    where [M].[AccountId] = @IdAccount
          and [M].[RowStatus] = 1
    order by DateCreated desc;
    ------------------------------------------------------------------------------------
    --Datos detalle de factura
    declare @dti_fk_header bigint;

    declare @dti_identification varchar(200) = 'SERVICIO';
    declare @dti_category varchar(50) = 'SERVICIO';
    declare @dti_quantity decimal(10, 5) = 1;
    declare @dti_measurement varchar(20) = 'UND';
    declare @dti_priceUnit money;
    declare @dti_description varchar(max) =
            (
                select top 1
                       [Description]
                from [dbo].[CatArticleSAP] with (nolock)
                where Name = 'MEMBRESIA ANUAL CLUB FORZA' collate Latin1_General_CI_AI
            );
    declare @dti_IVA money;
    declare @dti_amount money;
    declare @dti_dateRegister datetime = getdate();
    declare @dti_tokenRegister varchar(200) = @Token;
    declare @SAPCode nvarchar(50) =
            (
                select top 1
                       SAPCode
                from [dbo].[CatArticleSAP] with (nolock)
                where Name = 'MEMBRESIA ANUAL CLUB FORZA' collate Latin1_General_CI_AI
            );
    declare @SendToInvoice bit = 1;
    declare @Descriptionp as nvarchar(500);
    declare @SuscriptionDesc as nvarchar(200);
    declare @Authorizacion as nvarchar(20);
    declare @IdMemberOrSuscription as nvarchar(200);
    declare @MembershipId as int = null;
    declare @SubscriptionId as int = null;

    set @SuscriptionDesc =
    (
        select top 1
               isnull(SubscriptionName, '')
        from [dbo].[CatSubscription] with (nolock)
        where IdCatSubscription = @IdSalePackage
    );

    if (
           @SuscriptionDesc = 'Plan Básico'
           and @TypeSalePackage <> 'Membership' collate Latin1_General_CI_AI
       )
        set @dti_description =
    (
        select top 1
               [Description]
        from [dbo].[CatArticleSAP] with (nolock)
        where [Name] = 'SUSCRIPCION MENSUAL A' collate Latin1_General_CI_AI
    )   ;
    else if (
                @SuscriptionDesc = 'Plan Básico +'
                and @TypeSalePackage <> 'Membership' collate Latin1_General_CI_AI
            )
        set @dti_description =
    (
        select top 1
               [Description]
        from [dbo].[CatArticleSAP] with (nolock)
        where [Name] = 'SUSCRIPCION MENSUAL B' collate Latin1_General_CI_AI
    )   ;
    else if (
                @SuscriptionDesc = 'Plan Gold'
                and @TypeSalePackage <> 'Membership' collate Latin1_General_CI_AI
            )
        set @dti_description =
    (
        select top 1
               [Description]
        from [dbo].[CatArticleSAP] with (nolock)
        where [Name] = 'SUSCRIPCION MENSUAL C' collate Latin1_General_CI_AI
    )   ;
    else if (
                @SuscriptionDesc = 'Plan Corporativo'
                and @TypeSalePackage <> 'Membership' collate Latin1_General_CI_AI
            )
        set @dti_description =
    (
        select top 1
               [Description]
        from [dbo].[CatArticleSAP] with (nolock)
        where [Name] = 'SUSCRIPCION MENSUAL D' collate Latin1_General_CI_AI
    )   ;
    else if (
                @SuscriptionDesc = 'Plan Diamante'
                and @TypeSalePackage <> 'Membership' collate Latin1_General_CI_AI
            )
        set @dti_description =
    (
        select top 1
               [Description]
        from [dbo].[CatArticleSAP] with (nolock)
        where [Name] = 'MEMBRESIA DIAMANTE' collate Latin1_General_CI_AI
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
				  FROM [dbo].[MembershipPaymentLog] MOL WITH (NOLOCK) Where MembershipId = @IdMemberOrSuscription
				  ORDER BY MOL.DateCreated DESC


        END;
        ELSE
        BEGIN

					  IF(@inv_cli_nit = 'CF' And (Select  SubscriptionCost From [dbo].[CatSubscription] Where IdCatSubscription = @IdSalePackage) >= 2500)
					  BEGIN
								Select  TOP 1
										@inv_amount     = S.SubscriptionCost,
										@inv_cli_email  = @InvoiceEmail,
										@inv_cli_adress = @FiscalAddress,
										@inv_cli_nit    = REPLACE(@TaxId, '-', ''),
										@inv_cli_name   = @TaxName,
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
									@Authorizacion =  SOL.TransactionOrder,
									@typeMoneyId = SOL.TypeOfInOutOfMoneyId
								  FROM [dbo].[SubscriptionPaymentLog]  SOL WITH (NOLOCK) Where SubscriptionId = @IdMemberOrSuscription
								  ORDER BY SOL.DateCreated DESC

						IF(ISNULL(@TaxId, 'CF') <> 'CF')
						BEGIN
							UPDATE
								[M]
							SET
								InvoiceName = @TaxName
								,TaxIdNumber = @TaxId
								,InvoiceEmail = @InvoiceEmail
								,FiscalAddress = @FiscalAddress

							FROM	[DeliveryBackOffice].[dbo].[Membership] M 
							WHERE	[M].[AccountId] = @IdAccount AND [M].[RowStatus] = 1
						END
            
					 END
					ELSE IF(@inv_cli_nit = 'CF' And (Select  SubscriptionCost From [dbo].[CatSubscription] Where IdCatSubscription = @IdSalePackage) < 2500)
					  BEGIN
								Select  TOP 1
										@inv_amount     = S.SubscriptionCost,
										@inv_cli_email  = @InvoiceEmail,
										@inv_cli_adress = @FiscalAddress,
										@inv_cli_nit    = REPLACE(@TaxId, '-', ''),
										@inv_cli_name   = @TaxName,
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
									@Authorizacion =  SOL.TransactionOrder,
									@typeMoneyId = SOL.TypeOfInOutOfMoneyId
								  FROM [dbo].[SubscriptionPaymentLog]  SOL WITH (NOLOCK) Where SubscriptionId = @IdMemberOrSuscription
								  ORDER BY SOL.DateCreated DESC

						IF(ISNULL(@TaxId, 'CF') <> 'CF')
						BEGIN
							UPDATE
								[M]
							SET
								InvoiceName = @TaxName
								,TaxIdNumber = @TaxId
								,InvoiceEmail = @InvoiceEmail
								,FiscalAddress = @FiscalAddress

							FROM	[DeliveryBackOffice].[dbo].[Membership] M 
							WHERE	[M].[AccountId] = @IdAccount AND [M].[RowStatus] = 1
						END
					 END
					 ELSE IF(@inv_cli_nit = @TaxId)
					  BEGIN
								Select  TOP 1
										@inv_amount     = S.SubscriptionCost,
										@inv_cli_email  = M.InvoiceEmail,
										@inv_cli_adress = M.FiscalAddress,
										@inv_cli_nit    = REPLACE(M.TaxIdNumber, '-', ''),
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
								  FROM [dbo].[SubscriptionPaymentLog]  SOL WITH (NOLOCK) Where SubscriptionId = @IdMemberOrSuscription
								  ORDER BY SOL.DateCreated DESC
					 END
					 ELSE
					 BEGIN

								Select  TOP 1
										@inv_amount     = S.SubscriptionCost,
										@inv_cli_email  = @InvoiceEmail,
										@inv_cli_adress = @FiscalAddress,
										@inv_cli_nit    = REPLACE(@TaxId, '-', ''),
										@inv_cli_name   = @TaxName,
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
								  FROM [dbo].[SubscriptionPaymentLog]  SOL WITH (NOLOCK) Where SubscriptionId = @IdMemberOrSuscription
								  ORDER BY SOL.DateCreated DESC
					 END


        END;

		DECLARE @IdTypeFac INT;
		SET @IdTypeFac = (SELECT IdCatInvoiceType FROM CatInvoiceType WHERE NAME = 'Otros')


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
            inv_type,
			CatInvoiceTypeId
        )
        VALUES
        (@inv_vpCodeOfReferences, @inv_cmp_nit, @inv_cli_name, @inv_cli_adress, @inv_cli_nit, @inv_cli_email,
         @inv_date, @inv_IVA, @inv_amount, @inv_status, @inv_dateRegister, @inv_tokenRegister, 1,@IdTypeFac);


        set @dti_fk_header = scope_identity();

        insert into [dbo].[invoiceDetail]
        (
            dti_fk_header
          , dti_identification
          , dti_category
          , dti_quantity
          , dti_measurement
          , dti_priceUnit
          , dti_description
          , dti_IVA
          , dti_amount
          , dti_dateRegister
          , dti_tokenRegister
          , SAPCode
          , SendToInvoice
          , MembershipId
          , SubscriptionId
        )
        values
        (@dti_fk_header, @dti_identification, @dti_category, @dti_quantity, @dti_measurement, @inv_amount
       , @dti_description, @inv_IVA, @inv_amount, @dti_dateRegister, @dti_tokenRegister, @SAPCode, @SendToInvoice
       , @MembershipId, @SubscriptionId);

        insert into [dbo].[InOutOfMoneyDetail]
        (
            [io_type]
          , [io_vpCodeOfReferences]
          , [io_ticket]
          , [io_amount]
          , [io_status]
          , [io_invoice]
          , [io_registryToken]
          , [io_registryDate]
        )
        values
        (@typeMoneyId, @inv_vpCodeOfReferences, @Authorizacion, @inv_amount, @inv_status, @dti_fk_header, @Token
       , getdate());

        commit transaction;

        select Result                = 1
             , 'Transacción exitosa' as 'Description'
             , @dti_fk_header        IdInvoice
             , @inv_cli_email        inv_cli_email
             , @Token                Token;
    end try
    begin catch
        rollback transaction;
        select Result          = 0
             , error_message() as 'Description'
             , IdInvoice       = 0
             , @dti_fk_header  IdInvoice
             , @inv_cli_email  inv_cli_email
             , @Token          Token;

        insert into [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
        (
            [ErrorDescription]
          , [ErrorNumber]
          , [ErrorProcedure]
          , [ErrorLine]
          , [GuideSerie]
          , [GuideNumber]
          , [TokenCreated]
          , [DateCreated]
        )
        values
        (   cast(error_message() as nvarchar(300)) -- ErrorDescription - varchar(300)
          , error_number()                         -- ErrorNumber - int
          , error_procedure()                      -- ErrorProcedure - varchar(100)
          , error_line()                           -- ErrorLine - int
          , null                                   -- GuideSerie - nvarchar(2)
          , null                                   -- GuideNumber - int
          , ''                                     -- TokenCreated - varchar(50)
          , getdate()                              -- DateCreated - datetime
            );
    end catch;
end;
