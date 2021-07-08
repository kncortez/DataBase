USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_generate_report_to_commission_and_shipping_cod]    Script Date: 8/07/2021 14:32:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_generate_report_to_commission_and_shipping_cod]
	@BatchNumber INT,
	@StartDate DATETIME,
	@EndDate DATETIME
AS
BEGIN
--DECLARE @BatchNumber INT = null;
--DECLARE @StartDate DATETIME = null;
--DECLARE @EndDate DATETIME = getdate() - 5;

DECLARE @FormatDate NVARCHAR(8) = 'dd/MM/yy';
DECLARE @FlagBatchNumber INT = 0;
DECLARE @FlagDate INT = 0;
DECLARE @IdCountry NVARCHAR(2) = 'GT';
DECLARE @IdStatus INT = 1;
DECLARE @IdConceptCommision INT = 1;
DECLARE @IdConceptCOD INT = 2;
DECLARE @IdBankBAC INT = 31;
DECLARE @IdBankBANRURAL INT = 5;
DECLARE @IdBankBI INT = 33;

IF ISNULL(@BatchNumber, 0) = 0
BEGIN
	SET @FlagBatchNumber = 1;
END

IF ISNULL(@StartDate, 0) = 0
	AND ISNULL(@EndDate, 0) = 0
BEGIN
	SET @FlagDate = 1;
END

IF ISNULL(@StartDate, 0) = 0
BEGIN
	SET @StartDate = @EndDate;
END

IF ISNULL(@EndDate, 0) = 0
BEGIN
	SET @EndDate = GETDATE();
END

SELECT  
		--suba.Date,
		FORMAT(suba.Date, @FormatDate) 'FECHA LOTE',
		--suba.IdBatchCOD,
		--suba.BatchNumber,
		suba.BatchNumber 'LOTE OPERATIVO',
		--suba.BankIdBc,
		--suba.BankIdBdc,
		db.Name 'BANCO OPERATIVO',
		CONCAT(suba.GuideSerie, suba.GuideNumber) 'GUÍA',
		suba.Commission 'COMISIÓN ADMINISTRATIVA',
		--suba.Amount,
		(subb.Amount - subb.Commission) 'ENVÍO ADMINISTRATIVO',
		suba.Amount 'MONTO DEPOSITADO AL CLIENTE'
FROM (
	  SELECT bc.Date,
			 bc.IdBatchCOD,
			 bc.BatchNumber,
			 bc.BankId BankIdBc,
			 bdc.BankId BankIdBdc,
			 bdc.GuideSerie,
			 bdc.GuideNumber,
			 bdc.Commission,
			 bdc.Amount
	  FROM DeliveryBackOffice.dbo.BatchDetailCOD bdc
	  INNER JOIN DeliveryBackOffice.dbo.BatchCOD bc 
		ON bdc.BatchCODId = bc.IdBatchCOD
	  WHERE bdc.BatchCODId IN (
							   SELECT bc.IdBatchCOD 
							   FROM DeliveryBackOffice.dbo.BatchCOD bc 
							   WHERE (FORMAT(bc.Date, @FormatDate) 
										BETWEEN FORMAT(@StartDate, @FormatDate) 
										AND FORMAT(@EndDate, @FormatDate)
									  OR 1 = @FlagDate)
							   AND (bc.BatchNumber = @BatchNumber
									OR 1 = @FlagBatchNumber)
							  )
	  AND bdc.CatConceptCODId = @IdConceptCOD
	  AND bdc.BankId IN (@IdBankBANRURAL, @IdBankBI)
	 ) suba
INNER JOIN (
			SELECT bdc.GuideSerie,
				   bdc.GuideNumber,
				   bc.BankId BankIdBc,
				   bdc.BankId BankIdBdc,
				   bdc.Commission,
				   bdc.Amount
			FROM DeliveryBackOffice.dbo.BatchDetailCOD bdc
			INNER JOIN DeliveryBackOffice.dbo.BatchCOD bc
				ON bdc.BatchCODId = bc.IdBatchCOD
			WHERE bdc.BatchCODId IN (
									 SELECT bc.IdBatchCOD 
									 FROM DeliveryBackOffice.dbo.BatchCOD bc 
									 WHERE (FORMAT(bc.Date, @FormatDate) 
												BETWEEN FORMAT(@StartDate, @FormatDate) 
												AND FORMAT(@EndDate, @FormatDate)
											OR 1 = @FlagDate)
									 AND (bc.BatchNumber = @BatchNumber
										  OR 1 = @FlagBatchNumber)
									)
			AND bdc.CatConceptCODId = @IdConceptCommision
			AND bdc.BankId IN (@IdBankBAC)
		   ) subb
	ON suba.GuideSerie = subb.GuideSerie
	AND suba.GuideNumber = subb.GuideNumber
INNER JOIN DeliveryBackOffice.dbo.DeliveryBank db
	ON suba.BankIdBdc = db.Id_bank
	AND db.Id_country = @IdCountry
	AND db.Id_status = @IdStatus;
END


GO


