USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedFunction [dbo].[FnReviewServiceTargetHub]    Script Date: 10/12/2021 15:38:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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
				ISNULL(CAST(IIF(DSC1.Hub IS NOT NULL, DSC1.Hub, IIF(DSC2.Hub IS NOT NULL, DSC2.Hub, IIF(DSC3.Hub IS NOT NULL, DSC3.Hub, DSC4.Hub))) AS NVARCHAR),'') Hub
			FROM
				DeliveryBackOffice.dbo.DeliveryOrder DOR
				LEFT JOIN DeliveryBackOffice.dbo.Township TS
				ON
				DOR.ReceiverIdTownship = TS.IdTownship
				OR DOR.Receiver_Town = TS.TownshipName
				LEFT JOIN DeliveryBackOffice.dbo.Settlement S
				ON
				TS.IdTownship = S.IdTownship
				AND
				TS.IdProvince = S.IdProvince
				LEFT JOIN (SELECT DISTINCT TBHL.IdTownship IdTownship, HL.HubAbbreviation Hub FROM DeliveryBackOffice.dbo.TownshipByHubLogistic TBHL LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HL ON TBHL.IdHublogistic = HL.IdHubLogistic ) DSC2
				ON
				TS.IdTownship = DSC2.IdTownship
				LEFT JOIN (SELECT DISTINCT IdSettlement, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage) DSC1
				ON
				DOR.ReceiverIdSettlement = DSC1.IdSettlement
				LEFT JOIN (SELECT DISTINCT IdSettlement, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage) DSC3
				ON
				S.IdSettlement = DSC3.IdSettlement
				LEFT JOIN (SELECT DISTINCT HeaderCode, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage) DSC4
				ON
				TS.HeaderCode = DSC4.HeaderCode
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
				ISNULL(CAST(/*IIF(DSC1.Hub IS NOT NULL, DSC1.Hub,*/ IIF(DSC2.Hub IS NOT NULL, DSC2.Hub, IIF(DSC3.Hub IS NOT NULL, DSC3.Hub, DSC4.Hub))/*)*/ AS NVARCHAR),'') Hub
			FROM
				DeliveryBackOffice.dbo.DeliveryOrder DOR
				LEFT JOIN DeliveryBackOffice.dbo.Township TS
				ON
				DOR.SenderIdTownship = TS.IdTownship
				OR DOR.Sender_Town = TS.TownshipName
				LEFT JOIN DeliveryBackOffice.dbo.Settlement S
				ON
				TS.IdTownship = S.IdTownship
				AND
				TS.IdProvince = S.IdProvince
				LEFT JOIN (SELECT DISTINCT TBHL.IdTownship IdTownship, HL.HubAbbreviation Hub FROM DeliveryBackOffice.dbo.TownshipByHubLogistic TBHL LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HL ON TBHL.IdHublogistic = HL.IdHubLogistic ) DSC2
				ON
				TS.IdTownship = DSC2.IdTownship
				LEFT JOIN (SELECT DISTINCT IdSettlement, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage) DSC3
				ON
				S.IdSettlement = DSC3.IdSettlement
				LEFT JOIN (SELECT DISTINCT HeaderCode, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage) DSC4
				ON
				TS.HeaderCode = DSC4.HeaderCode
				WHERE
				DOR.Guide_Serie = @GuideSerie
				AND
				DOR.Guide_Number = @GuideNumber
		)
	END

	-- Condiciones de prioridad


    RETURN  @ReviewedHub;
END
GO


