-- =============================================  
-- Author:  <Andres, Ruiz>  
-- Create date: <2022-05-23>  
-- Description: < Obtiene los últimos datos de facturación de una guía >  
-- =============================================  
CREATE PROCEDURE [dbo].[GetGuideFCCBilling]   
 -- Add the parameters for the stored procedure here  
 @GuideNumber INT,  
 @GuideSerie NVARCHAR(2) = 'FD'  
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
 -- Variables "configurables"  
 DECLARE @GoodResponseMessage NVARCHAR(MAX) = CONCAT('Estimado cliente, la guía FD', @GuideNumber, ' contiene los siguientes datos de facturación, bajo el nombre <NAME>, con el nit <NIT>, facturada el <DATE>, con la certificación <CERT>.');  
 DECLARE @BadResponseMessage NVARCHAR(300) = CONCAT('Estimado cliente, le comentamos que la guía FD', @GuideNumber, ' no tiene datos de facturación.');  
 DECLARE @FailureResponseMessage NVARCHAR(300) = 'Estimado cliente, ha ocurrido un error al procesar su solicitud, por favor, intente de nuevo más tarde.';  
   
 DECLARE @ResponseTable AS TABLE(  
  GuideFELNumber NVARCHAR(50),  
  GuideFELCertification NVARCHAR(200),  
  GuideFELClientName NVARCHAR(500),  
  GuideFELClientNIT NVARCHAR(100),  
  GuideFELAmount MONEY,  
  GuideFELDate DATETIME  
 );  
  
 BEGIN TRY  
  
  INSERT INTO  
   @ResponseTable  
   (GuideFELNumber, GuideFELCertification, GuideFELClientName, GuideFELClientNIT, GuideFELAmount, GuideFELDate)  
  SELECT   
   TOP 1    
    InH.inv_numberFEL,   
    InH.inv_certificationFEL,  
    InH.inv_cli_name,   
    InH.inv_cli_nit,   
    InH.inv_amount,   
    InH.inv_date  
  FROM   
   dbo.invoiceheader InH WITH (NOLOCK)  
   INNER JOIN  
    dbo.invoicedetail InD WITH (NOLOCK)  
    On   
     InH.inv_pk_id = InD.dti_fk_header  
  WHERE   
   InD.dti_fk_orderSerie = @GuideSerie 
   AND  
   InD.dti_fk_orderNumber = @GuideNumber   
   And   
   InH.inv_certificationFEL IS NOT NULL  
   AND  
   InH.inv_creditNote IS NULL  
  
  IF( EXISTS(SELECT TOP 1 1 FROM @ResponseTable) )  
  BEGIN  
  
   SELECT  
    TOP 1  
     1 [blnResult]  
     ,REPLACE(REPLACE(REPLACE(REPLACE(@GoodResponseMessage,'<NAME>',RT.GuideFELClientName),'<NIT>',RT.GuideFELClientNIT),'<DATE>',REPLACE(CONVERT(NVARCHAR, RT.GuideFELDate, 103),'/',' de ')),'<CERT>',RT.GuideFELCertification) [messageResult]  
     ,@BadResponseMessage [badMessageResult]  
     ,@FailureResponseMessage [errorMessageResult]  
     ,RT.GuideFELNumber  
     ,RT.GuideFELCertification  
     ,RT.GuideFELClientName  
     ,RT.GuideFELClientNIT  
     ,RT.GuideFELAmount  
     ,RT.GuideFELDate  
   FROM  
    @ResponseTable RT  
  
  END  
  ELSE  
  BEGIN  
   
   SELECT  
    0 [blnResult] -- Indica que no existe un último estado publico posible de retornar  
    ,@BadResponseMessage [messageResult]  
  
  END  
  
 END TRY  
 BEGIN CATCH  
   
  SELECT  
   0 [blnResult] -- Indica que no existe un último estado publico posible de retornar  
   ,@FailureResponseMessage [messageResult]  
  
 END CATCH  
  
 INSERT INTO DeliveryBackOffice.dbo.RoutePreparationLogError  
   (  
       ErrorDescription,  
       ErrorNumber,  
       ErrorProcedure,  
       ErrorLine,  
       GuideSerie,  
       GuideNumber,  
       TokenCreated,  
       DateCreated  
   )  
   VALUES  
   (   'GetGuideFCCBilling',     -- ErrorDescription - varchar(300)  
       1,     -- ErrorNumber - int  
       'GetGuideFCCBilling',     -- ErrorProcedure - varchar(100)  
       NULL,     -- ErrorLine - int  
       NULL,     -- GuideSerie - nvarchar(2)  
       NULL,     -- GuideNumber - int  
       'SYS-BHERRERA',       -- TokenCreated - varchar(50)  
       GETDATE() -- DateCreated - datetime  
       )  
  
END