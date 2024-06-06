-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-29>
-- Description:	<SP para Modificar bandera de devolución (IsLastMileReturn)>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-29>
-- Description:	<Se realiza modificacion para invertir los codigos de pais para origen y destino al hacer una devolucion>
-- =============================================
CREATE procedure [dbo].[SPHD_ModifyReturnStatement]
    @TblListGuideActa TblListGuideActa readonly
  , @Token nvarchar(50)
as
begin

    set nocount on;

    begin transaction;
    begin try

        declare @SenderCountryId as nvarchar(2)='GT';
		declare @ReceiverCountryId as nvarchar(2)='GT';
        declare @Numero as int;
        declare @Serie as nvarchar(2);
        declare @STATUS as int;
        declare @STATUSDECLAREDRETURNED_DO int =
                (
                    select top 1
                           [SO].[StatusOrderId]
                    from [dbo].[StatusOrder] [SO] with (nolock)
                    where [OrderDescription] = 'Declarado para Devolución'
                );
        declare @StatusReversal int =
                (
                    select [StatusOrderId]
                    from [dbo].[StatusOrder]
                    where [OrderDescription] = 'Guía revertida para entrega'
                );
        declare @RevalueGuides as table
        (
            [GuideSerie] nvarchar(2)
          , [GuideNumber] int
        );
        declare @GuidesModify as table
        (
            [GuideSerie] nvarchar(2)
          , [GuideNumber] int
        );

        insert into @RevalueGuides
        select substring([lg].[NumberGuidePice], 1, 2)
             , cast(substring(ltrim([lg].[NumberGuidePice]), 3, cast(len([lg].[NumberGuidePice]) as int)) as int)
        from @TblListGuideActa [lg];

        ------------Modificar Bandera campo IsLastMileReturn ----------------------------
        while exists (select top 1 1 from @RevalueGuides)
        begin
            select top 1
                   @Serie  = [rg].[GuideSerie]
                 , @Numero = [rg].[GuideNumber]
            from @RevalueGuides [rg];

            select @STATUS = [DOD].[StatusOrderId],
				   @SenderCountryId = ISNULL([DO].[SenderCountryId],'GT'),
				   @ReceiverCountryId = ISNULL([DO].[ReceiverCountryId],'GT')
            from [dbo].[DeliveryOrderDetail] DOD with (nolock)
			inner join [dbo].[DeliveryOrder] DO with (nolock)
			on [DOD].[Guide_Serie] = [DO].[Guide_Serie] and [DOD].[Guide_Number] = [DO].[Guide_Number]
            where [DOD].[Guide_Serie] = @Serie
                  and [DOD].[Guide_Number] = @Numero;

            if (exists
            (
                select top 1
                       1
                from [dbo].[DeliveryOrder] with (nolock)
                where [Guide_Serie] = @Serie
                      and [Guide_Number] = @Numero
                      and
                      (
                          [IsLastMileReturn] = 0
                          or [IsLastMileReturn] is null
                      )
            )
               )
            begin

                -- Activar guía para devolución y asignar estado de "Declarado para devolución"
                update [dbo].[DeliveryOrder]
                set [IsLastMileReturn] = 1
                  , [StatusOrderId] = @STATUSDECLAREDRETURNED_DO
                  , [TokenUpdated] = @Token
                  , [DateUpdated] = getdate()
                  , [SenderCountryId] = @ReceiverCountryId
				  , [ReceiverCountryId] = @SenderCountryId
                where [Guide_Serie] = @Serie
                      and [Guide_Number] = @Numero;
                insert into @GuidesModify
                (
                    [GuideSerie]
                  , [GuideNumber]
                )
                values
                (@Serie, @Numero);

                -- Ingresar nuevo estado al historico
                insert into [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
                (
                    [Guide_Serie]
                  , [Guide_Number]
                  , [StatusOrderId]
                  , [UserCreated]
                  , [DateCreated]
                  , [DateCreatedInSystem]
                  , [RowStatus]
                )
                values
                (@Serie, @Numero, @STATUSDECLAREDRETURNED_DO, @Token, getdate(), getdate(), 1);
            end;
            else
            begin
                update [dbo].[DeliveryOrder]
                set [IsLastMileReturn] = 0
                  , [StatusOrderId] = @StatusReversal
                  , [TokenUpdated] = @Token
                  , [DateUpdated] = getdate()
                  , [SenderCountryId] = @ReceiverCountryId
				  , [ReceiverCountryId] = @SenderCountryId
                where [Guide_Serie] = @Serie
                      and [Guide_Number] = @Numero;
                insert into @GuidesModify
                (
                    [GuideSerie]
                  , [GuideNumber]
                )
                values
                (@Serie, @Numero);

                insert into [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
                (
                    [Guide_Serie]
                  , [Guide_Number]
                  , [StatusOrderId]
                  , [UserCreated]
                  , [DateCreated]
                  , [DateCreatedInSystem]
                  , [RowStatus]
                )
                values
                (@Serie, @Numero, @StatusReversal, @Token, getdate(), getdate(), 1);

                insert into @GuidesModify
                (
                    [GuideSerie]
                  , [GuideNumber]
                )
                values
                (@Serie, @Numero);
            end;

            delete from @RevalueGuides
            where [GuideSerie] = @Serie
                  and [GuideNumber] = @Numero;

        end;
        commit transaction;
        select [GuideSerie]
             , [GuideNumber]
        from @GuidesModify;

    end try
    begin catch
        rollback transaction;

        select 0                 [blnResult]
             , error_message()   [Description]
             , 0                 [NumTransferID]
             , error_number()    [ErrorNumber]
             , error_severity()  [ErrorSeverity]
             , error_state()     [ErrorState]
             , error_procedure() [ErrorProcedure]
             , error_line()      [ErrorLine]
             , error_message()   [ErrorMessage];
    end catch;


end;