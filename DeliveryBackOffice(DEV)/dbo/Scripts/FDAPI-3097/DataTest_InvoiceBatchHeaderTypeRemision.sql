INSERT INTO [InvoiceBatchHeader] 
(
[RTN],
[NoDeclaracion],
[CAI],
[LimitDateEmision],
[Establishment],
[Emision_Point],
[TypeDocument],
[RecepcionDate],
[Administration_Code],
[Status],
[Enable],
[InitialRange],
[FinalRange],
[Last_Process],
[AmountGranted],
[EmailNotification],
[DaysLeftNotifycation],
[PercentInvoiceLeftNotifycation],
[RowStatus],
[TokenCreated],
[DateCreated],
[TokenUpdated],
[DateUpdated],
[AmountRequested],
[companyName]
)
VALUES 
(
    -- Id_Lote --Autoincrementable
    '080019004244903',                         -- RTN
    '9273798276',                              -- NoDeclaracion
    'DF0EB8-654F16-0D4A8C-7AF3BD-41F163-AA',   -- CAI
    '2024-12-31',                              -- LimitDateEmision
    1,                                         -- Establishment
    1,                                         -- Emision_Point
    8,                                         -- TypeDocument
    '01-10-2024',                              -- RecepcionDate
    1001,                                      -- Administration_Code
    1,                                         -- Status (bit, true/false)
    1,                                         -- Enable (bit, true/false)
    100000000,                                 -- InitialRange
    100000500,                                 -- FinalRange
    100000020,                                 -- Last_Process
    500,                                       -- AmountGranted
    'juan.ramirez@forzadelivery.com',          -- EmailNotification
    15,                                        -- DaysLeftNotifycation
    10,                                        -- PercentInvoiceLeftNotifycation
    1,                                         -- RowStatus (bit, true/false)
    'SYS-DRAMIREZ',                            -- TokenCreated
    '2024-10-01',                              -- DateCreated
    NULL,                                      -- TokenUpdated
    NULL,                                      -- DateUpdated
    500,                                       -- AmountRequested
    'Company Name Example'                     -- companyName
);