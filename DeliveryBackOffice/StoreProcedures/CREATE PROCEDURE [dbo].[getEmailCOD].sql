USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sp_generate_file_cod]    Script Date: 26/06/2021 10:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[getEmailCOD]
	@IdBank INT
AS
BEGIN
--SELECT DISTINCT 
--STUFF((

SELECT rec.Email as EmailList,(select dbk.Acronym 
	FROM DeliveryBank dbk
	WHERE dbk.PayingBank = 5)  AS BankAcronym FROM CatEmailProcessCOD cep
JOIN CatReceiverEmailCOD rec ON cep.CatReceiverEmailCODId = rec.IdCatReceiverEmailCOD
WHERE cep.CatProcessCODId = 1 AND cep.RowStatus  = 1
--order by cep.CatReceiverEmailCODId
 --for xml path('')
 --   ),1,1,''
	--) as EmailList, dbk.Acronym AS BankAcronym
	--FROM DeliveryBank dbk
	--WHERE dbk.PayingBank = @IdBank

END