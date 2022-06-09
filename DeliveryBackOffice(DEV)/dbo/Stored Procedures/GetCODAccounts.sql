CREATE PROCEDURE [dbo].[GetCODAccounts]
    @VPCodeOfReference INT = 1,
	@IdClient INT = 1,
    @Token VARCHAR(100) = '0BE2F8F3BD53652635746ACD069954B5'
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);
   
    BEGIN

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, ISNULL(IdCustomer, 0)) + '",' + '"Name":"'
								               + dbo.fnt_String_Escape(REPLACE(ISNULL(cu.[Name], 'N/A'), '"',''),'json')   + '",' +'"Phone":"'+ISNULL([CustomerPhone],'')+ '",'
								               +'"Email":"'+ dbo.fnt_String_Escape(REPLACE(ISNULL([ContactEmail],''),'"',''),'json')  + '",'
                               +'"Cod":'+'[{'
								               +'"IdBank":"'+ CONVERT(NVARCHAR,  ISNULL([CODAccountBankID],''))+ '",'
										                 +'"BankDescription":"'+ CONVERT(NVARCHAR,  ISNULL(dbk.[Name],''))+ '",'
								               +'"Acronym":"'+ CONVERT(NVARCHAR,  ISNULL(dbk.[Acronym],''))+ '",'
								               +'"NameAccount":"'+ dbo.fnt_String_Escape(REPLACE(ISNULL([CODAccountName],''),'"',''),'json') + '",'
								               +'"TypeAccount":"'+ CONVERT(NVARCHAR, ISNULL(cba.[BankAccountType],''))+ '",'
								               +'"NumberAcc":"'+ dbo.fnt_String_Escape(REPLACE(ISNULL([CODAccountNumber],''),'-',''),'json')  + '",',
                               +'"DPI":"'+ REPLACE(ISNULL(cu.[LegalSponsorDPI],''),' ','') +'"'
								               +'}]'+
								               '}'
                                              FROM DeliveryBackOffice.dbo.Customer cu
								              LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbk ON cu.CODAccountBankID = dbk.Id_bank 
								              AND dbk.Id_country = 'GT'
								              AND dbk.Id_status = 1
								              LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType cba ON cu.CODAccountTypeID = cba.IdBankAccountType
								              AND cba.RowStatus = 1
								              LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc ON cu.IdCustomer = rc.RbcIdCustomer
								              AND rc.RbcRowStatus=1
								              LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment ccp ON ccp.IdConditionOfPayment = cu.ConditionOfPaymentID
								              WHERE IdCustomer = @IdClient
								              AND cu.RowSatus = 1
                                      AND RowSatus = 1
                                      ORDER BY IdCustomer
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    SELECT '[' + @jsonResult + ']' FormatJson;

END;
