-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-29>
-- Description:	<SP para Modificar bandera de devolución (IsLastMileReturn)>
-- =============================================
CREATE procedure [dbo].[SPHD_ModifyReturnStatement]
    @TblListGuideActa TblListGuideActa readonly
  , @Token nvarchar(50)
as
begin

    set nocount on;

    begin transaction;
    begin try


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

            select @STATUS = [StatusOrderId]
            from [dbo].[DeliveryOrderDetail] with (nolock)
            where [Guide_Serie] = @Serie
                  and [Guide_Number] = @Numero;

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