
CREATE PROCEDURE [dbo].[getEmailCOD]
	@IdBank INT
AS
BEGIN

SELECT rec.Email as EmailList,(select dbk.Acronym 
	FROM DeliveryBackOffice.dbo.DeliveryBank dbk
	WHERE dbk.Id_bank = @IdBank)  AS BankAcronym FROM CatEmailProcessCOD cep
JOIN DeliveryBackOffice.dbo.CatReceiverEmailCOD rec ON cep.CatReceiverEmailCODId = rec.IdCatReceiverEmailCOD
WHERE cep.CatProcessCODId = 1 AND cep.RowStatus  = 1
GROUP BY rec.Email


END