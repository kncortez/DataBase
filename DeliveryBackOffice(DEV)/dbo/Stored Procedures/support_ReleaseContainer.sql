CREATE PROCEDURE [dbo].[support_ReleaseContainer] @status NVARCHAR(100)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    DECLARE @tblStatus AS TABLE
    (
        ID INT,
        Nstatus NVARCHAR(20)
    );


    INSERT INTO @tblStatus
    (
        ID,
        Nstatus
    )
    SELECT *
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@status, ',');


    BEGIN TRY

        BEGIN TRANSACTION;

        UPDATE dbo.LinehaulRoutePreparationContainer
        SET CatLinehaulStatusId =
            (
                SELECT TOP 1
                       [IdCatLinehaulStatus]
                FROM [CatLinehaulStatus]
                WHERE [StatusName] = 'LIQUIDATED'
            )
        WHERE CatLinehaulStatusId IN
              (
                  SELECT [IdCatLinehaulStatus]
                  FROM [CatLinehaulStatus]
                  WHERE [StatusName] IN
                        (
                            SELECT Nstatus FROM @tblStatus
                        )
              );

        COMMIT TRANSACTION;

        SELECT 'Resgistros actualizado exitosamente';
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT CAST(ERROR_NUMBER() AS NVARCHAR) AS ErrorNumber,
               CAST(ERROR_SEVERITY() AS NVARCHAR) AS ErrorSeverity,
               CAST(ERROR_STATE() AS NVARCHAR) AS ErrorState,
               CAST(ERROR_PROCEDURE() AS NVARCHAR) AS ErrorProcedure,
               CAST(ERROR_LINE() AS NVARCHAR) AS ErrorLine,
               CAST(ERROR_MESSAGE() AS NVARCHAR) AS ErrorMessage;
    END CATCH;



END;