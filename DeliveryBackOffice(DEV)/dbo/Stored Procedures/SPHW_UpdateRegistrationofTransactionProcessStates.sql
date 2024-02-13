-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date, 2023-09-10>
-- Description:	<Description,Actualizar estado bandera del registro del inicio de una transcción, y actualizar a estado final>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_UpdateRegistrationofTransactionProcessStates]
@AccountId AS INT	
AS
BEGIN

	SET NOCOUNT ON;


	
BEGIN TRANSACTION
BEGIN TRY


		SET NOCOUNT ON; 
	

	DECLARE @IdCatProcessStates AS INT =(Select IdCatProcessStates From [dbo].[CatProcessStates] Where NameStatus = 'Finalizado')
	DECLARE @IdTrans AS INT = (Select Top 1 IdRegistrationofTransactionProcessStates From [dbo].[RegistrationofTransactionProcessStates]  Where
	                           AccountId = @AccountId And IdCatProcessStates = 1
	                           Order by DateCreated Desc)


    UPDATE  [dbo].[RegistrationofTransactionProcessStates] SET IdCatProcessStates = @IdCatProcessStates WHERE  IdRegistrationofTransactionProcessStates = @IdTrans


	COMMIT TRANSACTION
	SELECT 1 AS 'ResultCode' 


	END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

	SELECT
		500 'ResultCode',
		ERROR_MESSAGE() 'ResultMessage'
	
	END CATCH   
END