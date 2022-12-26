-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-11-24>
-- Description:	< Obtener información de punto de visita bajo codigo de referencia >
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetVisitPointDataByCodeOfReference]
    -- Add the parameters for the stored procedure here
    @IdVisitPoint AS INT = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	DECLARE @ResponseTable TABLE(
		CodeOfReference INT,
		DescriptionOfClient NVARCHAR(500),
		VisitPointPhone NVARCHAR(50),
		VisitPointAddress NVARCHAR(600)
	);

	BEGIN TRY
	
		-- Insert statements for procedure here
		INSERT INTO @ResponseTable
			(CodeOfReference, DescriptionOfClient, VisitPointAddress, VisitPointPhone)
		SELECT 
			   vpc.[CodeOfReference] [CodeOfReference],
			   vpc.[DescriptionOfClient] [DescriptionOfClient],
			   vpc.[Address],
			   vpc.[Phone]
		FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
			LEFT JOIN dbo.Township twn  WITH(NOLOCK)
				ON twn.IdTownship = vpc.IdTownship
			LEFT JOIN dbo.Province prv  WITH(NOLOCK)
				ON prv.IdProvince = twn.IdProvince
			LEFT JOIN dbo.VisitPointConfiguration vcf WITH(NOLOCK)
				ON vpc.CodeOfReference = vcf.VisitPointID
				AND vcf.RowStatus = 'TRUE'
			LEFT JOIN dbo.VisitPointFrequency vpf WITH(NOLOCK)
				ON vpf.VPConfigurationID = vcf.IdVPConfiguration
				AND vpf.RowStatus = 'TRUE'
		WHERE (
				  @IdVisitPoint = -1
				  OR vpc.CodeOfReference = @IdVisitPoint
			  );

		IF(EXISTS (SELECT TOP 1 1 FROM @ResponseTable))
		BEGIN
	
			SELECT
				200 'ResponseCode'

			SELECT
				RT.CodeOfReference
				,RT.DescriptionOfClient
				,RT.VisitPointAddress
				,RT.VisitPointPhone
			FROM
				@ResponseTable RT

		END
		ELSE
		BEGIN
		
			SELECT
				204 'ResponseCode'

			SELECT
				RT.CodeOfReference
				,RT.DescriptionOfClient
				,RT.VisitPointAddress
				,RT.VisitPointPhone
			FROM
				@ResponseTable RT

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 'ResponseCode'

	END CATCH

END;