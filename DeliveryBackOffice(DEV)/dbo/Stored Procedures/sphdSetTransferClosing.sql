-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,18-03-2022,>
-- Description:	<Description, Lista de Guías trasladadas a Exc Por Rabbit de Cierres>
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

	DECLARE @visitpoint int

				SET @visitpoint=(
					
						Select VPC.CodeOfReference
						      From dbo.InternalUser IU 
							                           INNER JOIN  dbo.VisitPointByUser VP
									ON IU.RegisterUserID=VP.RegisterUserID
									                   INNER JOIN dbo.VisitPointClient VPC
								    ON 		VP.IdVisitPointClient=VPC.IdVisitPointClient			   
									
							  WHERE  IU.IdUser = @IdUser
						      
								)
	
		
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
				  ,[VisitPoint]
				  )
			Select 
			         tdop.Guide_Serie
					,tdop.Guide_Number
					,1
					,(
						SELECT Top 1 B.IdTypeOfMoney 
							 FROM dbo.Cost A
									Left Join dbo.CostDetail B On A.IdCost=B.IdCost
							 WHERE A.ProductNumber = CONCAT(tdop.Guide_Serie,tdop.Guide_Number)
							 Order by B.DateCreated desc
					 )
					,ISNULL((Select Top 1 TimePlaId from dbo.DeliveryOrderPaymentDetail where GuideNumber=tdop.Guide_Number),1)
					,tdop.amount
					,1
					,tdop.TokenCreated
					,Getdate()
					,
						(SELECT TOP 1 IdTypeService FROM dbo.CatTypeServiceClosure WHERE NameTypeService = 'Traslado')
		              
					,@IdAcc--convert(Int,tdop.AccountId) as AccountId
					,@FEL
		            ,@visitpoint
			from @TblDeliveryOrdersList tdop



	END




		
END


