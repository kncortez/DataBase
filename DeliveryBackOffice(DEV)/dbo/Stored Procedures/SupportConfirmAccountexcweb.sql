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
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportConfirmAccountexcweb] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportConfirmAccountexcweb] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportConfirmAccountexcweb] TO [cvaldes]
    AS [dbo];

