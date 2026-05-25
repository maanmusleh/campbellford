pageextension 54002 "CFS Customer Report Selections" extends "Customer Report Selections"
{

    actions
    {
        addlast(Processing)
        {
            action("MRF Sales Document Setup")
            {
                ApplicationArea = All;
                Caption = 'Sales Document Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Setup Invoice and Credit Memo usage from Reports Selection';

                trigger OnAction()
                var
                    ReportSelections: Record "Report Selections";
                    CustomReportSelection: Record "Custom Report Selection";
                    Customer: Record Customer;
                begin
                    CustomReportSelection := Rec;
                    ReportSelections.SetFilter(Usage, '%1|%2',
                                "Report Selection Usage"::"S.Invoice",
                                "Report Selection Usage"::"S.Cr.Memo");

                    Customer.Get(Rec."Source No.");
                    if (Customer."E-Mail" = '') then
                        Message('Customer does not have an email address defined.');
                    Rec.CopyFromReportSelections(ReportSelections, Database::Customer, Customer."No.");
                    CurrPage.SetRecord(CustomReportSelection);
                end;
            }

            action("MRF Customer Statement Setup")
            {
                ApplicationArea = All;
                Caption = 'Customer Statement Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Setup Invoice and Credit Memo usage from Reports Selection';

                trigger OnAction()
                var
                    ReportSelections: Record "Report Selections";
                    CustomReportSelection: Record "Custom Report Selection";
                    Customer: Record Customer;
                begin
                    CustomReportSelection := Rec;
                    ReportSelections.SetRange(Usage,
                                "Report Selection Usage"::"C.Statement");

                    Customer.Get(Rec."Source No.");
                    if (Customer."E-Mail" = '') then
                        Message('Customer does not have an email address defined.');
                    Rec.CopyFromReportSelections(ReportSelections, Database::Customer, Customer."No.");
                    CurrPage.SetRecord(CustomReportSelection);
                end;
            }
        }
    }
}
