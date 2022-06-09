-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2021-09-07>
-- Update date: <2021-09-07>
-- Description:	<Obtiene un listado de guias que estan asociadas a un lote y tiene el estado en progreso (1)>
-- =============================================


CREATE PROCEDURE [dbo].[spws_Get_GuideBatch]
@IdAccount BIGINT =1,
@Token NVARCHAR(50) = '',
@IdBatch BIGINT = 0
AS

BEGIN

DECLARE @jsonResult NVARCHAR(MAX);
DECLARE @IdUser BIGINT = (SELECT RuaIdUser FROM DeliveryBackOffice.dbo.RolByUserByAccount WITH (NOLOCK) WHERE RuaIdAccount= @IdAccount);

   IF(@IdBatch=0)
   BEGIN
		SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"InternalCode":"' + ISNULL(vcp.InternalCode,'') + '",'
								                +'"ReceiverName":"'+ do.Receiver_FirstName + '",'
                                +'"ReceiverAddress":"'+ do.Receiver_Address + '",'
                                +'"GuideNumber":"FD'+ CONVERT(NVARCHAR,do.Guide_Number) + '",'
                                +'"Price":"'+ CAST(do.PriceShippment AS VARCHAR (200)) + '",'
                                +'"TypeOfService":"'+ do.TypeService + '",'
								+'"Pieces":"'+CONVERT(NVARCHAR,ISNULL(do.Pieces_Dry,'')) + '",'
								+'"IsCollect":'+CASE WHEN do.IsCollect=1 THEN 'true' ELSE 'false' END + ','
                                +'"COD":[{'
                                  +'"BankID":"'+ CONVERT(NVARCHAR,ISNULL(cu.CODAccountBankID,'')) +'",'
                                  +'"BankName":"'+ ISNULL(dbk.Name,'') +'",'
                                  +'"AccountName":"'+ ISNULL(cu.CODAccountName,'') +'",'
                                  +'"BankAccountNumber":"'+ ISNULL(cu.CODAccountNumber,'') +'",'
                                  +'"Amount":"'+ ISNULL(CAST(do.Collect_OnDelivery AS VARCHAR (200)),'') +'"'
								                +'}]}'
                                FROM DeliveryBackOffice.dbo.GuideBatch gb
                                JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio vcp ON vcp.IdVisitPointByClientPortfolio = gb.IdVisitPointByClientPortfolio
                                JOIN DeliveryBackOffice.dbo.UserAddress ua ON ua.UadIdAddress = gb.IdAddress
                                JOIN DeliveryBackOffice.dbo.RolByUserByAccount rba ON rba.RuaIdUser = gb.IdUser
                                JOIN DeliveryBackOffice.dbo.Account ac ON ac.AccIdAccount = rba.RuaIdAccount
                                JOIN DeliveryBackOffice.dbo.DeliveryOrder do ON do.Guide_Number = gb.GuideNumber
                                LEFT JOIN DeliveryBackOffice.dbo.Customer cu ON cu.IdCustomer = ac.IdCustomer
                                LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbk ON dbk.Id_bank = cu.CODAccountBankID
                                WHERE gb.IdUser = @IdUser AND gb.RowStatus=1 AND gb.Status=1
								                ORDER BY gb.GuideNumber
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
   END

   ELSE

   BEGIN

		SET @jsonResult =
        (
			SELECT '{"Orders":['+
					(SELECT STUFF(
                            (
                                SELECT ', "FD' +gb.GuideNumber+'"'
                                FROM DeliveryBackOffice.dbo.GuideBatch gb
								LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rba ON rba.RuaIdAccount=@IdAccount
                                WHERE gb.IdBatch = @IdBatch AND gb.IdUser= rba.RuaIdUser AND gb.RowStatus=1 AND gb.Status=2
								                ORDER BY gb.GuideNumber
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        ))
					+']}'
		);

   END

      -- Returns the results 
      SELECT('[' + ISNULL(@jsonResult,'{"Message":"No se encontraron guias pendientes de procesar.", "Results":false}') + ']') jsonResult;
END;
