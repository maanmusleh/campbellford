pageextension 54001 "CFS Customer List" extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            action(SendMonthlyStatement)
            {
                ApplicationArea = All;
                Caption = 'Send Monthly Statement';
                Image = Email;
                ToolTip = 'Send the monthly statement to the customer via delivery  method specified.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                    SendMonthlyStmt: Report "CFS Send Monthly Statements";

                begin
                    Customer.Reset();
                    Customer.SetRange("No.", Rec."No.");
                    clear(SendMonthlyStmt);
                    SendMonthlyStmt.SetTableView(Customer);
                    SendMonthlyStmt.SetStmtDelivery(Rec."CFS Statement Delivery");
                    SendMonthlyStmt.RunModal();
                end;
            }
        }
    }
}
