-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para mostrar listado de guías seleccionadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_getGuideList]
    @Token AS VARCHAR(50) = 'ad1a2328ed27ea99622f68deae5d9976',
    @Rol AS BIGINT = 1,
    @ListGuides AS VARCHAR(MAX) = ''
AS
--exec [dbo].[spg_get_RoutePreparation] @Department = 'Guatemala'
--exec dbo.spg_get_getGuideList @ListGuides='FD999,FD1015'
BEGIN


    CREATE TABLE #listGuides
    (
        Item NVARCHAR(100)
    );

    INSERT INTO #listGuides
    (
        Item
    )
    SELECT Item
    --into #listGuides
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@ListGuides, ',');


		 CREATE NONCLUSTERED INDEX IX_SettlementList_listGuides_getlist
            ON #listGuides (Item);

    SELECT serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) Guide,
           ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') Name,
           serv.Receiver_Address Address,
           serv.Receiver_Zone Zone,
           serv.Receiver_Town Town,
           serv.Receiver_Department Department
    FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
        INNER JOIN #listGuides lst
            ON lst.Item = Guide_Serie + CAST(Guide_Number AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AS;

END;
