CREATE PROCEDURE [dbo].[SupportGetHistoryRateByCustomer] @CustomerID INT
AS
BEGIN

    SELECT cs.IdCustomer          [IDCliente]
         , cs.Name                [Cliente]
         , rc.RbcDateCreated      [Fecha hora]
         , tk.SSN_Username        [Usuario]
         , rh.RheId               [IdTarifa]
         , rh.RheName             [Tarifario]
         , vp.DescriptionOfClient [Punto de Visita]
    FROM dbo.RatebyCustomer                           rc WITH (NOLOCK)
        INNER JOIN dbo.RateHeader                     rh WITH (NOLOCK)
            ON rh.RheId = rc.RbcIdRate
        INNER JOIN dbo.Customer                       cs WITH (NOLOCK)
            ON cs.IdCustomer = rc.RbcIdCustomer
        LEFT JOIN dbo.VisitPointClient                vp WITH (NOLOCK)
            ON vp.CodeOfReference = rc.RbcCodeOfReference
        LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
            ON tk.SSN_IdToken = rc.RbcTokenCreated
    WHERE rc.RbcIdCustomer = @CustomerID;
END;