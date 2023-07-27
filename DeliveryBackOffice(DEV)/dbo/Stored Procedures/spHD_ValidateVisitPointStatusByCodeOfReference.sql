-- =============================================
-- Author:		<Jerson, Ochoa>
-- Create date: <03-03-2023>
-- Description:	<Validate visit point status by Code of Reference>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_ValidateVisitPointStatusByCodeOfReference]
	@VPCodeOfReference INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF ( ISNULL(@VPCodeOfReference,-1) = -1 )
	BEGIN
	    SELECT
			CAST(0 AS BIT) [StatusClient]
	END
	ELSE
    BEGIN
        
		SELECT	CAST(ISNULL([VPC].[StatusClient], 0) AS BIT) [StatusClient]
		FROM	[dbo].[VisitPointClient] VPC
		WHERE	[VPC].[CodeOfReference] = @VPCodeOfReference;

    END
END