-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,18-03-2022,>
-- Description:	<Description, Lista de Guías trasladadas a Exc Por Rabbit de Cierres>
-- =============================================
-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,18-03-2022,>
-- Description:	<Description, Modificación para valdiar tiempo de pago de guias>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetTransferClosing]
    -- Add the parameters for the stored procedure here
    @TblDeliveryOrdersList dbo.TblDeliveryOrdersTransferList READONLY,
    @IdUser AS NVARCHAR(100),
    @FEL AS NVARCHAR(MAX)
AS
BEGIN


    SET NOCOUNT ON;


    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @IdAcc INT;
        IF (CAST(@IdUser AS INT) != 0)
        BEGIN
            SET @IdAcc =
            (
                SELECT ACC.AccIdAccount
                FROM dbo.InternalUser IU WITH (NOLOCK) -- campos e encuentra con el códigod e usuario logeado
                    INNER JOIN RegisterUser RU WITH (NOLOCK)
                        ON RU.UsrIdUser = IU.RegisterUserID
                    INNER JOIN RolByUserByAccount RB WITH (NOLOCK)
                        ON RB.RuaIdUser = RU.UsrIdUser
                    INNER JOIN Account ACC WITH (NOLOCK)
                        ON RB.RuaIdAccount = ACC.AccIdAccount
                WHERE IdUser = CAST(@IdUser AS INT)
            );
        END;

        IF (@IdAcc IS NOT NULL)
        BEGIN
            INSERT INTO dbo.DeliveryOrderPaymentTransaction
            (
                [GuideSerie],
                [GuideNumber],
                [PayTypeId],
                [TypeofInOutMoneyId],
                [TimePlaId],         --validar DeliveryOrderPaymentDetail
                [amount],
                [ShipmentCompleted], --en 1
                [TokenCreated],
                [DateCreated],       --Getdate()
                [TypeServiceId],
                [AccountId],
                [CODAmountProcess],
                [Fel]
            )
            SELECT tdop.Guide_Serie,
                   tdop.Guide_Number,
                   1,
                   ISNULL(
                   tdop_oa.IdTypeOfMoney,
                   1
                         ),
                   ISNULL(
                   (
                       SELECT TOP 1
                              TimePlaId
                       FROM dbo.DeliveryOrderPaymentDetail WITH (NOLOCK)
                       WHERE GuideSerie = 'FD' AND GuideNumber = tdop.Guide_Number
                   ),
                   1
                         ),
                   tdop.amount,
                   1,
                   tdop.TokenCreated,
                   GETDATE(),
                   (
                       SELECT TOP 1
                              IdTypeService
                       FROM dbo.CatTypeServiceClosure WITH (NOLOCK)
                       WHERE NameTypeService = 'Traslado'
                   ),
                   @IdAcc, --convert(Int,tdop.AccountId) as AccountId
                   0.00,
                   @FEL
            FROM @TblDeliveryOrdersList tdop
			inner join dbo.Cost A WITH (NOLOCK)				
				ON 
					A.ProductNumber = (CAST(tdop.Guide_Serie AS VARCHAR(2)) + CAST(tdop.Guide_Number AS VARCHAR(50)))
			OUTER APPLY(
				SELECT TOP 1
                              ISNULL(B.IdTypeOfMoney,1) IdTypeOfMoney
                       FROM dbo.CostDetail B WITH (NOLOCK)
                       WHERE 
						A.IdCost = B.IdCost
                       ORDER BY B.DateCreated DESC
			) tdop_OA
			WHERE 
				A.RowStatus=1;





        END;

        IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];



        INSERT INTO dbo.RoutePreparationLogError
        (
            ErrorDescription,
            ErrorNumber,
            ErrorProcedure,
            ErrorLine,
            GuideSerie,
            GuideNumber,
            TokenCreated,
            DateCreated
        )
        VALUES
        (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)), ERROR_LINE(),
         0  , 0, 'Error en rabbit', GETDATE());

    END CATCH;




END;


