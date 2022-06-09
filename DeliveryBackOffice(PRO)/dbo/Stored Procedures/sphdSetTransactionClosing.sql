-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,01-02-2022,>
-- Description:	<Description, Lista de Facturación de Cierres>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetTransactionClosing] 
	-- Add the parameters for the stored procedure here
	@TblDeliveryOrdersList dbo.TblDeliveryOrdersList4 READONLY,
	@IdUser as nvarchar(100),
	@FEL as nvarchar(MAX)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @IdAcc INT 
	
	IF (CAST(@IdUser AS INT) != 0)
	BEGIN
		SET @IdAcc = (
						select AccIdAccount from dbo.InternalUser IU -- campos e encuentra con el códigod e usuario logeado
							JOIN RegisterUser RU ON RU.UsrIdUser = IU.RegisterUserID
							JOIN RolByUserByAccount RB  ON RB.RuaIdUser = RU.UsrIdUser
							JOIN Account ACC ON RB.RuaIdAccount = ACC.AccIdAccount
						where IdUser = CAST(@IdUser AS INT)
		              )
	END
	
		
	IF ( @IdAcc IS NOT NULL )
	BEGIN

	DECLARE @VistitPointUser INT = (SELECT CodeOfReference FROM VisitPointClient VPC
								JOIN VisitPointByUser VPU
									ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
										AND VPU.RowStatus = 1
								JOIN RegisterUser ru
									ON VPU.RegisterUserID = ru.UsrIdUser
										AND ru.UsrRowStatus = 1
										JOIN RolByUserByAccount rua
								ON rua.RuaIdUser = ru.UsrIdUser
								WHERE rua.RuaIdAccount = @IdAcc)


			Insert into dbo.DeliveryOrderPaymentTransaction
				(  
				   [GuideSerie]
				  ,[GuideNumber]
				  ,[PayTypeId]
				  ,[TypeofInOutMoneyId]
				  ,[TimePlaId]--quemado en 1
				  ,[amount]
				  ,[ShipmentCompleted]--en 1
				  ,[TokenCreated]
				  ,[DateCreated]--Getdate()
				  ,[TypeServiceId]
				  ,[AccountId]
				  ,[FEL]
				  ,[VisitPoint]
				  )
			Select 
			         tdop.Guide_Serie
					,tdop.Guide_Number
					,1
					,tdop.TypeofInOutMoneyId
					,1
					,tdop.amount
					,1
					,tdop.TokenCreated
					,Getdate()
					,(
						Select IdTypeService From dbo.CatArticleSAPCatTypeServiceClosure Where SAPCode=tdop.IdTypeService
		              )
					,@IdAcc--convert(Int,tdop.AccountId) as AccountId
					,@FEL
					,IIF(@VistitPointUser=0,null, @VistitPointUser)
		
			from @TblDeliveryOrdersList tdop

 

	END
	

		
END
