CREATE PROCEDURE SupportConfirmAccountexcweb

			@AccConfirm VARCHAR(10),
			@IdCustomer INT	
	AS
	BEGIN
		UPDATE Account
		SET AccConfirm = @AccConfirm
		WHERE
	IdCustomer = @IdCustomer;
		END