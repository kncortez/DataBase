-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,01-02-2022,>
-- Description:	<Description, Lista de Facturación de Cierres>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetTransactionClosing] 
	-- Add the parameters for the stored procedure here
	@TblDeliveryOrdersList dbo.TblDeliveryOrdersList4 READONLY,
	@IdUser as nvarchar(100), 
	@IdTypeService as Int
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
 
 DECLARE @IdService int 
	
	
		SET @IdService = (
						Select IdTypeService From dbo.CatArticleSAPCatTypeServiceClosure Where SAPCode=@IdTypeService
		              )
	
		
	IF ( @IdAcc IS NOT NULL )
	BEGIN
			Insert into dbo.DeliveryOrderPaymentTransaction
				(  
				   [GuideSerie]
				  ,[GuideNumber]
				  ,[TypeofInOutMoneyId]
				  ,[TimePlaId]--quemado en 1
				  ,[amount]
				  ,[ShipmentCompleted]--en 1
				  ,[TokenCreated]
				  ,[DateCreated]--Getdate()
				  ,[TypeServiceId]
				  ,[AccountId]
				  )
			Select 
			         tdop.Guide_Serie
					,tdop.Guide_Number 
					,tdop.TypeofInOutMoneyId
					,1
					,tdop.amount
					,1
					,tdop.TokenCreated
					,Getdate()
					,@IdService
					,@IdAcc--convert(Int,tdop.AccountId) as AccountId
		
			from @TblDeliveryOrdersList tdop

 

	END
	

		
END
GO
