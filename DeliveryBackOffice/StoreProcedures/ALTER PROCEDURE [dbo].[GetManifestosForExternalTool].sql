USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetManifestosForExternalTool]    Script Date: 20/12/2021 14:30:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-08-18>
-- Description:	< Recupera datos de manifiestos bajo: fecha especifica, departamento especifico, municipio especifico y zonas especifias >
-- =============================================

ALTER PROCEDURE [dbo].[GetManifestosForExternalTool]
	@Date DATE,
	@Department NVARCHAR(50),
	@Town NVARCHAR(50),
	@Zones TblExtPlatTextParameterList READONLY
AS
BEGIN
	/*
		DECLARE @Date DATE = '2021-07-30';
		DECLARE @Department NVARCHAR(50) = 'guatemala';
		DECLARE @Town NVARCHAR(50) = 'guatemala';
		DECLARE @Zones TblExtPlatTextParameterList; 
		INSERT @Zones VALUES('15'),('16');
	*/
	SELECT DISTINCT
		DOS.ID Manifesto
	FROM
		(
			SELECT DISTINCT
			Guide_Serie,
			Guide_Number,
			ID_Courier
			FROM dbo.DeliveryAttempt
		) DAT
		JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR
			ON DAT.Guide_Serie = DOR.Guide_Serie
			AND DAT.Guide_Number = DOR.Guide_Number
		JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD
			ON DSD.Guide_Serie = DOR.Guide_Serie
			AND DSD.Guide_Number = DOR.Guide_Number
			AND DSD.RowStatus = 1
		JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS
			ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
			AND DOS.ID_Courier = DAT.ID_Courier
		JOIN @Zones TZP
			ON TZP.TextParameter = DOR.Receiver_Zone
	WHERE
		CAST(DOS.Route_Dispatched AS DATE) = CAST(@Date AS DATE)
		AND
		(LOWER(DOR.Receiver_Town) = @Town)
		AND
		(LOWER(DOR.Receiver_Department) = @Department)
END;