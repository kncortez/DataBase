-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-03-16>
-- Description:	<Description,Validar si el estado de la guía es terminal>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidateTerminalStatus]
@GuideSerie nvarchar(2),
@GuideNumber int

AS
BEGIN
	

	DECLARE @StatusActualId   int = (Select DO.StatusOrderId From [dbo].[DeliveryOrder] DO With(Nolock) Where DO.Guide_Serie= @GuideSerie And DO.Guide_Number = @GuideNumber)
	DECLARE @Status nvarchar(100) = (Select SO.OrderDescription From [dbo].[StatusOrder] SO Where SO.StatusOrderId = @StatusActualId)
	SET NOCOUNT ON;

	BEGIN TRY

	IF(@StatusActualId IS NULL OR @StatusActualId='')
	BEGIN

	 SELECT 3 AS 'STATUSTYPE', @Status AS [Status]
	END
	ELSE
			BEGIN
			-- Insert statements for procedure here
			IF(EXISTS(SELECT
				  1
				FROM
					[dbo].[StatusOrder] SO  WITH(NOLOCK)
				WHERE
					SO.[CatCheckpointTypeId] = 3 And SO.StatusOrderId = @StatusActualId)
				)

				BEGIN
					SELECT 1 AS 'STATUSTYPE', @Status AS [Status]
				END
				ELSE
					BEGIN
						SELECT 0 AS 'STATUSTYPE', @Status AS [Status]
			
					END
		  END
  END TRY
  BEGIN CATCH

	SELECT 4 AS 'STATUSTYPE', 'No Definido' AS [Status]

  END CATCH
END