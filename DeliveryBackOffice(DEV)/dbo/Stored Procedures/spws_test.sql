CREATE PROCEDURE [dbo].[spws_test]
    @GuideSerie VARCHAR(2) = 'FD'
AS
BEGIN
SELECT *
    INTO #testBNHL
    FROM DeliveryBackOffice.dbo.SplitStrings('EXP076', ',');
	
	SELECT * FROM #testBNHL

	END

--EXEC [dbo].[spws_test]