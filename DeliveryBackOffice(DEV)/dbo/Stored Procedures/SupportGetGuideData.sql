
CREATE PROCEDURE [dbo].[SupportGetGuideData]
    @GuideSerie [varchar](4) ,	
	@GuideNumber INT 	
	
AS
BEGIN
	
	
--  Información General ---
select 'Información General'   as Descripcion
     , ord.DateCreated         'Fecha Creación'
	 ,cs.IdCustomer 'IdCliente'
     , cs.Name                 'Cliente'
	 , ord.Sender_Mail 'Correo remitente'
     , cty.Description         'Tipo de Cliente'
     , cpy.ConditionOfPayment  'Codiciones de pago'
	 , vpc.CodeOfReference 'Codigo de punto de visita'
     , vpc.DescriptionOfClient 'Punto de visita'
     , ord.Guide_Serie         'Serie'
     , ord.Guide_Number        'Guía'
     , ord.IsCollect           'Collect'
     , ord.PriceShippment      'Precio'
     , ord.Collect_OnDelivery  'COD'
     , sy.SysNameSystem        'Sistema'
     , st.OrderDescription     'Estado'
     , ord.IsLastMileReturn    'Devolucion'
	 , ord.TypeService 'Tipo de Servicio'
	 , ord.InsuranceAmount 'Monto Asergurado'
	 , ord.IsInsuarance 'Esta Aasegurada?'
	 , ord.Pieces_Dry
	 ,ord.Pieces_Cold
	 , imp.DescriptionOfClient 'Impersonado'
from dbo.DeliveryOrder                  ord with (nolock)
    left join dbo.Customer              cs with (nolock)
        on cs.IdCustomer = ord.IdCustomer
    left join dbo.CustomerType          cty with (nolock)
        on cty.IdCustomerType = cs.IdCustomerType
    left join dbo.CatConditionOfPayment cpy with (nolock)
        on cpy.IdConditionOfPayment = cs.ConditionOfPaymentID
    left join dbo.VisitPointClient      vpc with (nolock)
        on vpc.CodeOfReference = ord.Sender_ID
    left join dbo.CatSystem             sy with (nolock)
        on sy.SysIdSystem = ord.CatSystemId
    inner join dbo.StatusOrder          st with (nolock)
        on st.StatusOrderId = ord.StatusOrderId
	LEFT JOIN dbo.VisitPointClient imp WITH(NOLOCK)
	ON imp.CodeOfReference = ord.OriginSenderId
where ord.Guide_Serie = @GuideSerie
      and ord.Guide_Number = @GuideNumber;


-- Información de Pago --
select 'Información de Pago' as Descripcion
     , cs.ProductNumber 'Guía'
     , cs.TotalAmount 'Monto de guía'
     , cs.TotalAmountPaid 'Monto Pagado'
 from dbo.Cost cs with (nolock)
where cs.GuideSerie = @GuideSerie
      and cs.GuideNumber = @GuideNumber;

-- Condiciones de pago

select 'Condiciones de Pago' as Descripcion
     , dpd.GuideSerie 'Serie'
     , dpd.GuideNumber 'Guía'
     , pt.TimePlaName 'Momento de pago'
from dbo.DeliveryOrderPaymentDetail dpd with (nolock)
    left join dbo.CatPaymentTime    pt with (nolock)
        on pt.TimePlaId = dpd.TimePlaId
where dpd.GuideSerie = @GuideSerie
      and dpd.GuideNumber = @GuideNumber;



-- Facturación ----
select distinct
       'Información de Facturación' as Descripcion
     , ivh.inv_date                 'Fecha'
     , ivh.inv_cli_nit              'NIt'
     , ivh.inv_cli_name             'Cliente'
     , ivh.inv_cli_email            'Correo'
     , ivh.inv_certificationFEL     'Certificación Fel'
     , ivh.inv_amount               'Monto'
     , ivh.inv_invoiceOfCreditNote  'Nota de crédito'
from dbo.invoiceDetail           ivd with (nolock)
    inner join dbo.invoiceHeader ivh with (nolock)
        on ivh.inv_pk_id = ivd.dti_fk_header
where ivd.dti_fk_orderSerie = @GuideSerie
      and ivd.dti_fk_orderNumber = @GuideNumber;


select 'Información de Rutas de entrega '       as Descripcion
     , sdo.ID                                   'Manifiesto'
     , sdo.Date_Dispatched                      'Fecha de Despacho'
     , sdo.Date_Received                        'Fecha de Liquidación'
     , CR.CodeRoute                             'Ruta'
     , concat(SR.First_Name, ' ', SR.Last_Name) 'Courierman'
     , SR.Phone                                 'Teléfono de Courierman'
     , CV.UnitNumber
from dbo.DeliverySettlementDetail            sdt with (nolock)
    inner join dbo.DeliveryOrderBySettlement sdo with (nolock)
        on sdo.ID = sdt.ID_DeliveryOrderBySettlement
    inner join dbo.SenderReceiver            SR with (nolock)
        on SR.ID = sdo.ID_Courier
    inner join dbo.CatRoute                  CR
        on CR.IdRoute = sdo.CatRouteId
    inner join dbo.CatVehicle                CV
        on CV.IdVehicle = sdo.CatVehicleId
where sdt.Guide_Serie = @GuideSerie
      and sdt.Guide_Number = @GuideNumber
      and sdt.RowStatus = 1;

SELECT 'Cuenta Bancaria'
, dcb.DCBA_Id
     , dcb.DCBA_Num_account
     , dcb.DCBA_Nom_account
     , dcb.DCBA_BankAccountType
     , bk.Name
FROM dbo.DeliveryOrder                         ord
    INNER JOIN dbo.DeliveryCustomerBankAccount dcb
        ON dcb.DCBA_Id = ord.DCBA_ID
    INNER JOIN dbo.DeliveryBank                bk
        ON bk.Id_bank = dcb.DCBA_Bank_Id
WHERE ord.Guide_Serie = @GuideSerie
      AND ord.Guide_Number = @GuideNumber;

select 'Información de COD'    as Descripcion
     , pr.GuideSerie           'Serie'
     , pr.GuideNumber          'Guía'
     , btd.AuthorizationDate   'Fecha de Depósito'
     , btd.Amount              'Monto'
     , btd.AuthorizationNumber 'Autorizacion'
     , bcd.BatchNumber         'Lote'
     , bcd.BatchTimeRange      'Horario'
	 
from dbo.ProcessedGuideCOD        pr
    inner join dbo.BatchDetailCOD btd with (nolock)
        on btd.GuideSerie = pr.GuideSerie
           and btd.GuideNumber = pr.GuideNumber
           and btd.CatConceptCODId = 2
           and btd.RowStatus = 1
    inner join dbo.BatchCOD       bcd with (nolock)
        on bcd.IdBatchCOD = btd.BatchCODId
           and bcd.RowStatus = 1
where pr.GuideSerie = @GuideSerie
      and pr.GuideNumber = @GuideNumber;


select 'Cambios en Monto COD' as Descripcion
     , cod.GuideSerie         'Serie'
     , cod.GuideNumber        'Guia'
     , cod.OldCODAmount       'COD original'
     , cod.NewCODAmount       'Nuevo Cod'
     , tk.SSN_IdUser          'Ficha'
     , tk.SSN_Username        'Usuario'
     , tk.SSN_DateLogin       'Fecha y Hora'
from dbo.AuthorizationLogCOD                       cod with (nolock)
    inner join DenariusUser_Dev.dbo.LGN_LogByToken tk with (nolock)
        on tk.SSN_IdToken = cod.TokenCreated
where cod.GuideSerie = @GuideSerie
      and cod.GuideNumber = @GuideNumber
order by cod.DateCreated desc;



select 'Tracking'                                                                             as Descripcion
     , dtd.Guide_Serie 'Serie'
     , dtd.Guide_Number 'Guia'
     , dtd.StatusOrderId 'Id Estado'
     , st.OrderDescription 'Estado'
     , isnull(tk.SSN_Username, isnull(rg.UsrEmail, concat(sr.First_Name, ' ', sr.Last_Name))) 'Usuario'
     , dtd.DateCreated 'Fecha y Hora'
	 , stp.CheckpointTypeDescription 'Tipo de estado'
from dbo.DeliveryOrderDetail                      dtd with (nolock)
    inner join dbo.StatusOrder                    st with (nolock)
        on st.StatusOrderId = dtd.StatusOrderId
    left join DenariusUser_Dev.dbo.LGN_LogByToken tk with (nolock)
        on tk.SSN_IdToken = dtd.UserCreated
    left join dbo.TokenLog                        TKL
        on TKL.TknIdToken = dtd.UserCreated
    left join dbo.RegisterUser                    rg
        on rg.UsrIdUser = TKL.TknIdUser
    left join dbo.LogTokenPOD                     TKP
        on TKP.LogTokenPOD = dtd.UserCreated
    left join dbo.SenderReceiver                  sr
        on sr.ID = TKP.IdCourierman
	inner join dbo.CatCheckpointType stp on stp.IdCatCheckpointType = st.CatCheckpointTypeId
where dtd.Guide_Serie = @GuideSerie
      and dtd.Guide_Number = @GuideNumber
order by dtd.DateCreated desc;

END