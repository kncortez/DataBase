CREATE PROCEDURE CutStringFelName(@NewName NVARCHAR(100), @IDNumber INT)
AS
	BEGIN
		UPDATE invoiceHeader
		SET inv_cmp_nameFEL = @NewName
		WHERE inv_pk_id = @IDNumber
	END