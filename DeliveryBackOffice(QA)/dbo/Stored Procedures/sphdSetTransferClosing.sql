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
	@IdUser as nvarchar(100),
	@FEL as nvarchar(MAX)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @IdAcc INT 
	IF (CAST(@IdUser AS INT) != 0)
	BEGIN
		SET @IdAcc = (
						select ACC.AccIdAccount from dbo.InternalUser IU -- campos e encuentra con el códigod e usuario logeado
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
				  ,[TimePlaId]--validar DeliveryOrderPaymentDetail
				  ,[amount]
				  ,[ShipmentCompleted]--en 1
				  ,[TokenCreated]
				  ,[DateCreated]--Getdate()
				  ,[TypeServiceId]
				  ,[AccountId]
				  ,[CODAmountProcess]
				  ,[FEL]
				  )
			Select 
			         tdop.Guide_Serie
					,tdop.Guide_Number
					,1
					,ISNULL(
						(SELECT Top 1 B.IdTypeOfMoney
							 FROM dbo.Cost A WITH (NOLOCK)
									Left Join dbo.CostDetail B WITH (NOLOCK) ON A.IdCost=B.IdCost
							 WHERE A.ProductNumber = CONCAT(tdop.Guide_Serie,tdop.Guide_Number)
							 Order by B.DateCreated desc),1
					 )
					,ISNULL((Select Top 1 TimePlaId from dbo.DeliveryOrderPaymentDetail where GuideNumber=tdop.Guide_Number),1)
					,tdop.amount
					,1
					,tdop.TokenCreated
					,Getdate()
					,
						(SELECT TOP 1 IdTypeService FROM dbo.CatTypeServiceClosure WHERE NameTypeService = 'Traslado')
		              
					,@IdAcc--convert(Int,tdop.AccountId) as AccountId
					,0.00
					,@FEL
		
			from @TblDeliveryOrdersList tdop

 

	END




		
END


