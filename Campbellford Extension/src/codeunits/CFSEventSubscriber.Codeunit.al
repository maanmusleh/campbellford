codeunit 54000 "CFS Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Custom Report Selection", OnCopyFromReportSelectionsOnBeforeInsert, '', false, false)]
    local procedure "Custom Report Selection_OnCopyFromReportSelectionsOnBeforeInsert"(var CustomReportSelection: Record "Custom Report Selection"; ReportSelections: Record "Report Selections")
    var
        Customer: Record Customer;
    begin
        if (CustomReportSelection."Source Type" = Database::Customer)
            and (Customer.Get(CustomReportSelection."Source No."))
            and (ReportSelections.Usage In [
                    ReportSelections.Usage::"C.Statement",
                    ReportSelections.Usage::"S.Invoice",
                    ReportSelections.Usage::"S.Cr.Memo"]) then begin
            CustomReportSelection.Validate("Send To Email", Customer."E-Mail");
        end;
    end;
}
