-- =============================================
-- Author:        <Freddy Camposeco>
-- Create date:   <2025-11-13>
-- Description:   <Obtiene los identificadores de estados finales activos>
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[spws_get_final_status_ids]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT StatusOrderId
    FROM dbo.StatusOrder WITH (NOLOCK)
    WHERE CatCheckpointTypeId = 3
      AND RowStatus = 1;
END;
GO
