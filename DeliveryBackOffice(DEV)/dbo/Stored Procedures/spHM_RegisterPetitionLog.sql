

-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-11-25>
-- Description:	<proceso para almacenar en bitacora la informacion del consumo de servicios web de API mobile>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_RegisterPetitionLog] 
	-- Add the parameters for the stored procedure here
	@PetitionMethod nvarchar(10),
	@PetitionUrl nvarchar(MAX),
	@RequestHeader nvarchar(4000),
	@RequestBody nvarchar(MAX) = '',
	@RequestDateTime datetime = NULL,
	@RequestLauValue nvarchar(500)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--IF(@RequestDateTime IS NULL)
	--	SET @RequestDateTime = GETDATE()

	--DECLARE @InsertedLog AS TABLE (
	--	IdInsert BIGINT
	--);

	--BEGIN TRANSACTION
	--BEGIN TRY

		--INSERT INTO [DeliveryBackOffice].[dbo].[APIMobileLog]
		--	(
		--		[PetitionMethod]
		--		,[PetitionUrl]
		--		,[RequestHeader]
		--		,[RequestBody]
		--		,[RequestDateTime]
		--		,[RequestLauValue]
		--	)
		--OUTPUT inserted.IdAPIMobileLog INTO @InsertedLog(IdInsert)
		--VALUES
		--(
		--	@PetitionMethod
		--	,@PetitionUrl
		--	,@RequestHeader
		--	,@RequestBody
		--	,@RequestDateTime
		--	,@RequestLauValue
		--)

		--IF(EXISTS (SELECT TOP 1 1 FROM @InsertedLog))
		--BEGIN

		--	COMMIT TRANSACTION;

			SELECT
				TOP 1
					200 'ResultCode',
					1 'ResultLog'
			--		IL.IdInsert 'ResultLog'
			--FROM
			--	@InsertedLog IL

	--	END
	--	ELSE
	--	BEGIN

	--		ROLLBACK TRANSACTION;

	--		SELECT
	--			204 'ResultCode'

	--	END
	--END TRY
	--BEGIN CATCH
	--	ROLLBACK TRANSACTION;

	--	SELECT
	--		500 'ResultCode'

	--END CATCH
END