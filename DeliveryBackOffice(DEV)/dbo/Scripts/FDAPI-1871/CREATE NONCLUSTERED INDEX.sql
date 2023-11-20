CREATE NONCLUSTERED INDEX [idx_dti_fk_header_dti_fk_orderSerie_dti_fk_orderNumber]
ON invoiceDetail (dti_fk_header,dti_fk_orderSerie, dti_fk_orderNumber)

CREATE NONCLUSTERED INDEX [idx_PaymentTransaction]
ON DeliveryORderPaymentTransaction(TypeOfInOutMoneyId, DateCreated)
INCLUDE (amount,TypeServiceId,AccountId, CODAmountProcess,VisitPoint, Fel)

CREATE NONCLUSTERED INDEX [idx_AccountClosures]
ON AccountingClosuresDetail (AccountingClosuresHeaderId, RowStatus)
INCLUDE (Fel)