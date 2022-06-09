-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-10>
-- Description:	< Retorna la abreviación de Hub de origen o destino de una guía >
-- =============================================
CREATE FUNCTION [dbo].[FnReviewServiceTargetHub]
(
    @GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Target INT = 1 -- 1 = Entregas | 2 = Recolecciones
)
RETURNS NVARCHAR(10) 
AS
BEGIN
    DECLARE @ReviewedHub NVARCHAR (10) = '';

	IF (@Target = 1)
	BEGIN
		SET @ReviewedHub = (
			SELECT TOP 1
				RTRIM(LTRIM(ISNULL(DSC1.Hub,'N/A'))) Hub
			FROM
				DeliveryBackOffice.dbo.DeliveryOrder DOR WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Township TS WITH(NOLOCK)
					ON
					DOR.ReceiverIdTownship = TS.IdTownship
					OR DOR.Receiver_Town = TS.TownshipName
				LEFT JOIN (
					SELECT
						DSC.HeaderCode
						,MAX(DSC.Hub) 'Hub'
					FROM
						[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
					GROUP BY
						DSC.HeaderCode
				) DSC1
					ON
					TS.HeaderCode = DSC1.HeaderCode
				WHERE
					DOR.Guide_Serie = @GuideSerie
					AND
					DOR.Guide_Number = @GuideNumber
		)
	END
	IF (@Target = 2)
	BEGIN
		SET @ReviewedHub = (
			SELECT TOP 1
				RTRIM(LTRIM(ISNULL(DSC1.Hub,'N/A'))) Hub
			FROM
				DeliveryBackOffice.dbo.DeliveryOrder DOR WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Township TS WITH(NOLOCK)
					ON
					DOR.SenderIdTownship = TS.IdTownship
					OR DOR.Sender_Town = TS.TownshipName
				LEFT JOIN (
					SELECT
						DSC.HeaderCode
						,MAX(DSC.Hub) 'Hub'
					FROM
						[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
					GROUP BY
						DSC.HeaderCode
				) DSC1
					ON
					TS.HeaderCode = DSC1.HeaderCode
				WHERE
				DOR.Guide_Serie = @GuideSerie
				AND
				DOR.Guide_Number = @GuideNumber
		)
	END

	-- Condiciones de prioridad


    RETURN  @ReviewedHub;
END
