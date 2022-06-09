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
						Select Top 1 IdTypeService From dbo.CatArticleSAPCatTypeServiceClosure Where SAPCode=tdop.IdTypeService
		              )
					,@IdAcc--convert(Int,tdop.AccountId) as AccountId
					,@FEL
		
			from @TblDeliveryOrdersList tdop

 

	END
	

		
END
