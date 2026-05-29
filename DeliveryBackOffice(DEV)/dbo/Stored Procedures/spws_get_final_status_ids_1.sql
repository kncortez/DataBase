-- =============================================
-- Author:        <Freddy Camposeco>
-- Create date:   <2025-11-13>
-- Description:   <Obtiene los identificadores de estados finales activos>
-- =============================================
CREATE   PROCEDURE [dbo].[spws_get_final_status_ids]
AS
BEGIN
  SET ANSI_NULLS ON
  SET QUOTED_IDENTIFIER ON
  SET NOCOUNT ON;

  SELECT StatusOrderId
  FROM dbo.StatusOrder WITH (NOLOCK)
  WHERE CatCheckpointTypeId = 3
    AND RowStatus = 1;
END;