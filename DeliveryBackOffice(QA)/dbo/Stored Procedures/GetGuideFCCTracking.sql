-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-23>
-- Description:	< Devuelve los estados publicos de la guía para rastrear el progreso en el ciclo de vida >
-- =============================================

CREATE PROCEDURE [dbo].[GetGuideFCCTracking] 
	@GuideNumber INT,
	@GuideSerie NVARCHAR(2) = 'FD'

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Variables "configurables"
	DECLARE @GoodResponseMessage NVARCHAR(MAX) = CONCAT('Estimado cliente, la guía FD', @GuideNumber, ' se encuentra en el estado <STATUS> desde el <DATE>, gracias por usar nuestros servicios.');
	DECLARE @FailureResponseMessage NVARCHAR(300) = 'Estimado cliente, ha ocurrido un error al procesar su solicitud, por favor, intente de nuevo más tarde.';
	
	DECLARE @ResponseTable AS TABLE(
		GuideNumber INT,
		GuideStatus INT,
		GuideStatusDescription NVARCHAR(50),
		GuideStatusDate DATETIME
	);

	DECLARE @ExternalTypeId INT = (
		SELECT
			TOP 1
				CST.IdCatStatusType
		FROM
			[DeliveryBackOffice].[dbo].[CatStatusType] CST
		WHERE
			CST.StatusType = 'Externo' COLLATE Latin1_General_CI_AI
	)

	BEGIN TRY

		INSERT INTO
			@ResponseTable
			(GuideNumber, GuideStatus, GuideStatusDescription, GuideStatusDate)
		SELECT 
			TOP 1  
				DOD.Guide_Number
				,DOD.StatusOrderId
				,SO.OrderDescription
				,DOD.DateCreated
		From 
			[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
				On 
					DOD.StatusOrderId = SO.StatusOrderId
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
				On 
					SO.CatStatusTypeId = CST.IdCatStatusType
		Where 
			DOD.Guide_Number = @GuideNumber
			AND
			DOD.Guide_Serie = @GuideSerie
			AND 
			CST.IdCatStatusType = @ExternalTypeId
		ORDER BY
			DOD.DateCreated DESC

		IF( EXISTS (SELECT TOP 1 1 FROM @ResponseTable) )
		BEGIN

			SELECT
				TOP 1
					1 [blnResult]
					,REPLACE(REPLACE(@GoodResponseMessage,'<STATUS>',RT.GuideStatusDescription),'<DATE>',REPLACE(CONVERT(NVARCHAR, RT.GuideStatusDate, 103),'/',' de ')) [messageResult]
					,@FailureResponseMessage [errorMessageResult]
					,RT.GuideNumber
					,RT.GuideStatus
					,RT.GuideStatusDate
					,RT.GuideStatusDescription
			FROM
				@ResponseTable RT

		END
		ELSE
		BEGIN

			SELECT
				0 [blnResult] -- Indica que no existe un último estado publico posible de retornar
				,@FailureResponseMessage [messageResult]
		END
	END TRY
	BEGIN CATCH
	
		SELECT
			0 [blnResult] -- Indica que no existe un último estado publico posible de retornar
			,@FailureResponseMessage [messageResult]

	END CATCH
END
