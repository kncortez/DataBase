USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[CreateWorkflow]    Script Date: 4/03/2026 17:07:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =================================================
   SP:        CreateWorkflow
   Propósito: Se registra un nuevo flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  ---
   Fecha:     2026-03-04

=== CHANGELOG ============================
=========================================== */
ALTER PROCEDURE [dbo].[CreateWorkflow]
	@Name NVARCHAR(50),
	@Token NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO DeliveryBackOffice.dbo.Workflow
            (Name, DateCreated, TokenCreated)
        VALUES
            (@Name, GETDATE(), @Token);

        SELECT CAST(SCOPE_IDENTITY() AS BIGINT);
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            SELECT 0;
        ELSE
            THROW;
    END CATCH
END;