
CREATE PROCEDURE [dbo].[getEmailCOD]
	@IdBank INT
AS
BEGIN
DECLARE @DEBUG BIT = 'TRUE';
IF @DEBUG = 'TRUE' 
BEGIN
SELECT DISTINCT 'oscar.morales@forzalatam.com' as EmailList,(select dbk.Acronym 
	FROM DeliveryBackOffice.dbo.DeliveryBank dbk
	WHERE dbk.Id_bank = @IdBank)  AS BankAcronym FROM CatEmailProcessCOD cep
JOIN DeliveryBackOffice.dbo.CatReceiverEmailCOD rec ON cep.CatReceiverEmailCODId = rec.IdCatReceiverEmailCOD
WHERE cep.CatProcessCODId = 1 AND cep.RowStatus  = 1
UNION
SELECT DISTINCT 'marco.jimenez@forzalatam.com' as EmailList,(select dbk.Acronym 
	FROM DeliveryBackOffice.dbo.DeliveryBank dbk
	WHERE dbk.Id_bank = @IdBank)  AS BankAcronym FROM CatEmailProcessCOD cep
JOIN DeliveryBackOffice.dbo.CatReceiverEmailCOD rec ON cep.CatReceiverEmailCODId = rec.IdCatReceiverEmailCOD
WHERE cep.CatProcessCODId = 1 AND cep.RowStatus  = 1
GROUP BY rec.Email
UNION
SELECT DISTINCT 'alfredo.monroy@forzalatam.com' as EmailList,(select dbk.Acronym 
	FROM DeliveryBackOffice.dbo.DeliveryBank dbk
	WHERE dbk.Id_bank = @IdBank)  AS BankAcronym FROM CatEmailProcessCOD cep
JOIN DeliveryBackOffice.dbo.CatReceiverEmailCOD rec ON cep.CatReceiverEmailCODId = rec.IdCatReceiverEmailCOD
WHERE cep.CatProcessCODId = 1 AND cep.RowStatus  = 1
GROUP BY rec.Email
END



ELSE
BEGIN
SELECT rec.Email as EmailList,(select dbk.Acronym 
	FROM DeliveryBackOffice.dbo.DeliveryBank dbk
	WHERE dbk.Id_bank = @IdBank)  AS BankAcronym FROM CatEmailProcessCOD cep
JOIN DeliveryBackOffice.dbo.CatReceiverEmailCOD rec ON cep.CatReceiverEmailCODId = rec.IdCatReceiverEmailCOD
WHERE cep.CatProcessCODId = 1 AND cep.RowStatus  = 1
GROUP BY rec.Email
END


END